import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_habit_engine/models/check_in.dart';
import 'package:pocket_habit_engine/models/habit_experiment.dart';

void main() {
  test('experiment map preserves the local storage shape', () {
    final source = HabitExperiment(
      id: 8,
      title: 'Wind down',
      cue: 'I close my laptop',
      action: 'write one line',
      startDate: DateTime(2026, 2, 10),
      targetDays: 14,
      createdAt: DateTime(2026, 2, 10, 8, 30),
    );

    final restored = HabitExperiment.fromMap(source.toMap());

    expect(restored.id, 8);
    expect(restored.title, source.title);
    expect(restored.statement, 'After I close my laptop, I will write one line.');
    expect(restored.startDate, DateTime(2026, 2, 10));
    expect(restored.targetDays, 14);
  });

  test('check-in map preserves completion and notes', () {
    final source = CheckIn(
      id: 3,
      experimentId: 8,
      day: DateTime(2026, 2, 11),
      completed: true,
      note: 'The small version felt easy.',
      createdAt: DateTime(2026, 2, 11, 7),
    );

    final restored = CheckIn.fromMap(source.toMap());

    expect(restored.id, 3);
    expect(restored.experimentId, 8);
    expect(restored.day, DateTime(2026, 2, 11));
    expect(restored.completed, isTrue);
    expect(restored.note, source.note);
  });
}