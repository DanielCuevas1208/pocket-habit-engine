import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      join(databasePath, 'pocket_habit_engine.db'),
      version: 1,
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE experiments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            cue TEXT NOT NULL,
            action TEXT NOT NULL,
            start_date TEXT NOT NULL,
            target_days INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            archived INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await database.execute('''
          CREATE TABLE check_ins (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            experiment_id INTEGER NOT NULL,
            day TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            note TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            UNIQUE(experiment_id, day),
            FOREIGN KEY(experiment_id) REFERENCES experiments(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _database!;
  }
}
