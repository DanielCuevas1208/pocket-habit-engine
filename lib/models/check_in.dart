import '../core/date_tools.dart';

class CheckIn {
  const CheckIn({
    this.id,
    required this.experimentId,
    required this.day,
    required this.completed,
    required this.note,
    required this.createdAt,
  });

  final int? id;
  final int experimentId;
  final DateTime day;
  final bool completed;
  final String note;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'experiment_id': experimentId,
      'day': DateTools.key(day),
      'completed': completed ? 1 : 0,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CheckIn.fromMap(Map<String, Object?> map) {
    return CheckIn(
      id: map['id'] as int?,
      experimentId: map['experiment_id'] as int,
      day: DateTools.fromKey(map['day'] as String),
      completed: (map['completed'] as int) == 1,
      note: map['note'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
