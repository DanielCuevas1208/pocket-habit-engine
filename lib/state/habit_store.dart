import 'package:flutter/foundation.dart';

import '../core/date_tools.dart';
import '../data/habit_repository.dart';
import '../models/check_in.dart';
import '../models/habit_experiment.dart';
import '../domain/experiment_insights.dart';

class HabitStore extends ChangeNotifier {
  HabitStore({HabitRepository? repository})
      : _repository = repository ?? HabitRepository();

  final HabitRepository _repository;
  final Map<int, List<CheckIn>> _checkIns = <int, List<CheckIn>>{};
  List<HabitExperiment> _experiments = <HabitExperiment>[];
  bool isLoading = true;
  String? errorMessage;

  List<HabitExperiment> get experiments => List.unmodifiable(_experiments);

  List<CheckIn> checkInsFor(HabitExperiment experiment) {
    return List.unmodifiable(_checkIns[experiment.id] ?? <CheckIn>[]);
  }

  CheckIn? checkInFor(HabitExperiment experiment, DateTime day) {
    final key = DateTools.key(day);
    for (final checkIn in _checkIns[experiment.id] ?? <CheckIn>[]) {
      if (DateTools.key(checkIn.day) == key) return checkIn;
    }
    return null;
  }

  int get completedToday {
    return _experiments.where((experiment) {
      return checkInFor(experiment, DateTools.today())?.completed ?? false;
    }).length;
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.seedIfEmpty();
      _experiments = await _repository.getExperiments();
      _checkIns.clear();
      for (final experiment in _experiments) {
        if (experiment.id != null) {
          _checkIns[experiment.id!] =
              await _repository.getCheckIns(experiment.id!);
        }
      }
    } catch (_) {
      errorMessage = 'The local journal could not open.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createExperiment(HabitExperiment experiment) async {
    final id = await _repository.createExperiment(experiment);
    final saved = HabitExperiment(
      id: id,
      title: experiment.title,
      cue: experiment.cue,
      action: experiment.action,
      startDate: experiment.startDate,
      targetDays: experiment.targetDays,
      createdAt: experiment.createdAt,
    );
    _experiments = <HabitExperiment>[saved, ..._experiments];
    _checkIns[id] = <CheckIn>[];
    notifyListeners();
  }

  Future<void> toggleToday(HabitExperiment experiment) async {
    await toggleDay(experiment, DateTools.today());
  }

  Future<void> toggleDay(HabitExperiment experiment, DateTime day) async {
    final existing = checkInFor(experiment, day);
    final checkIn = CheckIn(
      id: existing?.id,
      experimentId: experiment.id!,
      day: day,
      completed: !(existing?.completed ?? false),
      note: existing?.note ?? '',
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await _repository.saveCheckIn(checkIn);
    final entries = _checkIns[experiment.id] ?? <CheckIn>[];
    entries
        .removeWhere((entry) => DateTools.key(entry.day) == DateTools.key(day));
    entries.add(checkIn);
    entries.sort((a, b) => a.day.compareTo(b.day));
    _checkIns[experiment.id!] = entries;
    notifyListeners();
  }

  Future<void> saveNote(HabitExperiment experiment, String note) async {
    final day = DateTools.today();
    final existing = checkInFor(experiment, day);
    final checkIn = CheckIn(
      id: existing?.id,
      experimentId: experiment.id!,
      day: day,
      completed: existing?.completed ?? false,
      note: note.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await _repository.saveCheckIn(checkIn);
    final entries = _checkIns[experiment.id] ?? <CheckIn>[];
    entries
        .removeWhere((entry) => DateTools.key(entry.day) == DateTools.key(day));
    entries.add(checkIn);
    entries.sort((a, b) => a.day.compareTo(b.day));
    _checkIns[experiment.id!] = entries;
    notifyListeners();
  }

  double rateFor(HabitExperiment experiment) {
    return ExperimentInsights.completionRate(
        experiment, checkInsFor(experiment));
  }
}
