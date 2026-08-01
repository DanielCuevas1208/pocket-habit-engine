import '../core/date_tools.dart';

class HabitExperiment {
  const HabitExperiment({
    this.id,
    required this.title,
    required this.cue,
    required this.action,
    required this.startDate,
    required this.targetDays,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String cue;
  final String action;
  final DateTime startDate;
  final int targetDays;
  final DateTime createdAt;

  String get statement => 'After $cue, I will $action.';

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'title': title,
      'cue': cue,
      'action': action,
      'start_date': DateTools.key(startDate),
      'target_days': targetDays,
      'created_at': createdAt.toIso8601String(),
      'archived': 0,
    };
  }

  factory HabitExperiment.fromMap(Map<String, Object?> map) {
    return HabitExperiment(
      id: map['id'] as int?,
      title: map['title'] as String,
      cue: map['cue'] as String,
      action: map['action'] as String,
      startDate: DateTools.fromKey(map['start_date'] as String),
      targetDays: map['target_days'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}