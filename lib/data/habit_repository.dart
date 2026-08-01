import 'package:sqflite/sqflite.dart';

import '../core/date_tools.dart';
import '../models/check_in.dart';
import '../models/habit_experiment.dart';
import 'app_database.dart';

class HabitRepository {
  HabitRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<HabitExperiment>> getExperiments() async {
    final database = await _database.database;
    final rows = await database.query(
      'experiments',
      where: 'archived = ?',
      whereArgs: <Object>[0],
      orderBy: 'created_at DESC',
    );
    return rows.map(HabitExperiment.fromMap).toList();
  }

  Future<List<CheckIn>> getCheckIns(int experimentId) async {
    final database = await _database.database;
    final rows = await database.query(
      'check_ins',
      where: 'experiment_id = ?',
      whereArgs: <Object>[experimentId],
      orderBy: 'day ASC',
    );
    return rows.map(CheckIn.fromMap).toList();
  }

  Future<int> createExperiment(HabitExperiment experiment) async {
    final database = await _database.database;
    return database.insert('experiments', experiment.toMap());
  }

  Future<void> saveCheckIn(CheckIn checkIn) async {
    final database = await _database.database;
    await database.insert(
      'check_ins',
      checkIn.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> seedIfEmpty() async {
    final database = await _database.database;
    final count = Sqflite.firstIntValue(
          await database.rawQuery('SELECT COUNT(*) FROM experiments'),
        ) ??
        0;
    if (count > 0) return;

    final start = DateTools.daysFromToday(-6);
    final experimentId = await database.insert(
      'experiments',
      HabitExperiment(
        title: 'Morning light',
        cue: 'I finish my first coffee',
        action: 'step outside for five minutes',
        startDate: start,
        targetDays: 14,
        createdAt: DateTime.now(),
      ).toMap(),
    );
    final completedOffsets = <int>[-6, -5, -3, -1, 0];
    for (final offset in completedOffsets) {
      await saveCheckIn(
        CheckIn(
          experimentId: experimentId,
          day: DateTools.daysFromToday(offset),
          completed: true,
          note: offset == -3 ? 'The short version still helped.' : '',
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}