import '../core/date_tools.dart';
import '../models/check_in.dart';
import '../models/habit_experiment.dart';

class ExperimentInsights {
  const ExperimentInsights._();

  static int elapsedDays(HabitExperiment experiment, {DateTime? through}) {
    final end = through ?? DateTools.today();
    if (end.isBefore(experiment.startDate)) return 0;
    final elapsed = DateTools.inclusiveDaysBetween(experiment.startDate, end);
    return elapsed < experiment.targetDays ? elapsed : experiment.targetDays;
  }

  static int completedDays(
    HabitExperiment experiment,
    Iterable<CheckIn> checkIns, {
    DateTime? through,
  }) {
    final requestedEnd = through ?? DateTools.today();
    final experimentEnd =
        DateTools.addDays(experiment.startDate, experiment.targetDays - 1);
    final end =
        requestedEnd.isBefore(experimentEnd) ? requestedEnd : experimentEnd;
    return checkIns
        .where((checkIn) =>
            checkIn.completed &&
            !checkIn.day.isBefore(experiment.startDate) &&
            !checkIn.day.isAfter(end))
        .map((checkIn) => DateTools.key(checkIn.day))
        .toSet()
        .length;
  }

  static double completionRate(
    HabitExperiment experiment,
    Iterable<CheckIn> checkIns, {
    DateTime? through,
  }) {
    final window = elapsedDays(experiment, through: through);
    if (window == 0) return 0;
    return completedDays(experiment, checkIns, through: through) / window;
  }

  static List<DateTime> daysForRange(DateTime end, int length) {
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return List<DateTime>.generate(
      length,
      (index) => DateTools.addDays(normalizedEnd, -length + index + 1),
    );
  }

  static double sevenDayRate(Iterable<CheckIn> checkIns, {DateTime? through}) {
    final end = through ?? DateTools.today();
    final keys = daysForRange(end, 7).map(DateTools.key).toSet();
    final completed = checkIns
        .where((checkIn) =>
            checkIn.completed && keys.contains(DateTools.key(checkIn.day)))
        .map((checkIn) => DateTools.key(checkIn.day))
        .toSet()
        .length;
    return completed / 7;
  }
}
