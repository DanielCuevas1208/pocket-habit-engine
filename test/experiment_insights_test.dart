import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_habit_engine/core/date_tools.dart';
import 'package:pocket_habit_engine/domain/experiment_insights.dart';
import 'package:pocket_habit_engine/models/check_in.dart';
import 'package:pocket_habit_engine/models/habit_experiment.dart';

void main() {
  final experiment = HabitExperiment(
    id: 1,
    title: 'Read',
    cue: 'I make tea',
    action: 'read two pages',
    startDate: DateTime(2026, 1, 1),
    targetDays: 7,
    createdAt: DateTime(2026, 1, 1),
  );

  test('counts completed days inside the experiment window', () {
    final checkIns = <CheckIn>[
      _checkIn(experiment.id!, DateTime(2026, 1, 1), completed: true),
      _checkIn(experiment.id!, DateTime(2026, 1, 3), completed: true),
      _checkIn(experiment.id!, DateTime(2026, 1, 4), completed: true),
      _checkIn(experiment.id!, DateTime(2026, 1, 5), completed: false),
      _checkIn(experiment.id!, DateTime(2025, 12, 31), completed: true),
      _checkIn(experiment.id!, DateTime(2026, 1, 10), completed: true),
    ];

    expect(
      ExperimentInsights.completedDays(experiment, checkIns, through: DateTime(2026, 1, 4)),
      3,
    );
    expect(
      ExperimentInsights.completionRate(experiment, checkIns, through: DateTime(2026, 1, 4)),
      0.75,
    );
    expect(
      ExperimentInsights.completedDays(experiment, checkIns, through: DateTime(2026, 1, 10)),
      3,
    );
  });

  test('returns an ordered seven-day range', () {
    final days = ExperimentInsights.daysForRange(DateTime(2026, 1, 7), 7);

    expect(days.first, DateTime(2026, 1, 1));
    expect(days.last, DateTime(2026, 1, 7));
    expect(days.map(DateTools.key).toSet(), hasLength(7));
  });

  test('calculates the seven-day review rate', () {
    final checkIns = <CheckIn>[
      _checkIn(experiment.id!, DateTime(2026, 1, 1), completed: true),
      _checkIn(experiment.id!, DateTime(2026, 1, 3), completed: true),
      _checkIn(experiment.id!, DateTime(2026, 1, 7), completed: true),
    ];

    expect(
      ExperimentInsights.sevenDayRate(checkIns, through: DateTime(2026, 1, 7)),
      closeTo(3 / 7, 0.0001),
    );
  });
}

CheckIn _checkIn(int experimentId, DateTime day, {required bool completed}) {
  return CheckIn(
    experimentId: experimentId,
    day: day,
    completed: completed,
    note: '',
    createdAt: DateTime(2026, 1, 1),
  );
}