import 'package:flutter/material.dart';

import '../../core/date_tools.dart';
import '../../domain/experiment_insights.dart';
import '../../models/habit_experiment.dart';
import '../../state/habit_store.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen(
      {required this.store, required this.onOpenExperiment, super.key});

  final HabitStore store;
  final ValueChanged<HabitExperiment> onOpenExperiment;

  @override
  Widget build(BuildContext context) {
    final experiments = store.experiments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Habit Engine'),
        actions: <Widget>[
          IconButton(
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Pocket Habit Engine',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Local-first habit experiments.',
            ),
            icon: const Icon(Icons.info_outline),
            tooltip: 'About this app',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: store.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: <Widget>[
            Text('Test one small change.',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Notice what helps. Keep what fits.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: const Color(0xFF577069)),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    label: 'Active',
                    value: '${experiments.length}',
                    icon: Icons.radio_button_checked,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Today',
                    value: '${store.completedToday}',
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Your experiments',
                    style: Theme.of(context).textTheme.titleLarge),
                Text(
                  DateTools.monthAndDay(DateTools.today()),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: const Color(0xFF577069)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (experiments.isEmpty) const _EmptyExperimentState(),
            for (final experiment in experiments) ...<Widget>[
              _ExperimentCard(
                experiment: experiment,
                store: store,
                onTap: () => onOpenExperiment(experiment),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard(
      {required this.experiment, required this.store, required this.onTap});

  final HabitExperiment experiment;
  final HabitStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rate = store.rateFor(experiment);
    final elapsed = ExperimentInsights.elapsedDays(experiment);
    final todayIsComplete =
        store.checkInFor(experiment, DateTools.today())?.completed ?? false;
    return Semantics(
      button: true,
      label: 'Open ${experiment.title} experiment',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(experiment.title,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            experiment.statement,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color(0xFF577069)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      todayIsComplete
                          ? Icons.check_circle
                          : Icons.chevron_right,
                      color: todayIsComplete
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF8A9A91),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: rate.clamp(0.0, 1.0).toDouble(),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE3EBE4),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('$elapsed of ${experiment.targetDays} days',
                        style: Theme.of(context).textTheme.labelLarge),
                    Text('${(rate * 100).round()}% observed',
                        style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyExperimentState extends StatelessWidget {
  const _EmptyExperimentState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(Icons.spa_outlined,
                size: 42, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('Make room for one experiment.',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
                'Use the button below to define a routine worth noticing.'),
          ],
        ),
      ),
    );
  }
}
