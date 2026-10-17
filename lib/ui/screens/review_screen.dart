import 'package:flutter/material.dart';

import '../../core/date_tools.dart';
import '../../domain/experiment_insights.dart';
import '../../models/check_in.dart';
import '../../models/habit_experiment.dart';
import '../../state/habit_store.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({required this.store, super.key});

  final HabitStore store;

  @override
  Widget build(BuildContext context) {
    final experiments = store.experiments;
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: <Widget>[
          Text('Look for a pattern.',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'A record is useful even when the routine changes.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: const Color(0xFF577069)),
          ),
          const SizedBox(height: 24),
          if (experiments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Start an experiment to see its seven-day view.'),
              ),
            ),
          for (final experiment in experiments) ...<Widget>[
            _ReviewCard(
              experiment: experiment,
              checkIns: store.checkInsFor(experiment),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          const _ReviewNote(),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.experiment, required this.checkIns});

  final HabitExperiment experiment;
  final List<CheckIn> checkIns;

  @override
  Widget build(BuildContext context) {
    final sevenDayRate = ExperimentInsights.sevenDayRate(checkIns);
    final overallRate = ExperimentInsights.completionRate(experiment, checkIns);
    final completed = ExperimentInsights.completedDays(experiment, checkIns);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(experiment.title,
                        style: Theme.of(context).textTheme.titleMedium)),
                Text('${(sevenDayRate * 100).round()}% this week',
                    style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$completed completed day${completed == 1 ? '' : 's'} so far',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: const Color(0xFF577069)),
            ),
            const SizedBox(height: 20),
            Semantics(
              label:
                  '${(sevenDayRate * 100).round()} percent completed across the last seven days',
              child: _CompletionChart(checkIns: checkIns),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Icon(Icons.flag_outlined,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Overall observation: ${(overallRate * 100).round()}%')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionChart extends StatelessWidget {
  const _CompletionChart({required this.checkIns});

  final List<CheckIn> checkIns;

  @override
  Widget build(BuildContext context) {
    final days = ExperimentInsights.daysForRange(DateTools.today(), 7);
    return Column(
      children: <Widget>[
        SizedBox(
          height: 120,
          width: double.infinity,
          child: CustomPaint(
              painter: _ChartPainter(days: days, checkIns: checkIns)),
        ),
        Row(
          children: days
              .map(
                (day) => Expanded(
                  child: Text(
                    DateTools.shortWeekday(day).substring(0, 1),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: const Color(0xFF577069)),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.days, required this.checkIns});

  final List<DateTime> days;
  final List<CheckIn> checkIns;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE3EBE4)
      ..strokeWidth = 1;
    final completedPaint = Paint()
      ..color = const Color(0xFF3C7466)
      ..style = PaintingStyle.fill;
    final pendingPaint = Paint()
      ..color = const Color(0xFFDDE5DD)
      ..style = PaintingStyle.fill;
    final chartHeight = size.height - 8;
    for (final fraction in <double>[0, 0.5, 1]) {
      final y = chartHeight - chartHeight * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final barWidth = size.width / (days.length * 1.8);
    for (var index = 0; index < days.length; index++) {
      final dayKey = DateTools.key(days[index]);
      final complete = checkIns.any((checkIn) =>
          checkIn.completed && DateTools.key(checkIn.day) == dayKey);
      final left = index * (size.width / days.length) +
          (size.width / days.length - barWidth) / 2;
      final barHeight = complete ? chartHeight * 0.82 : chartHeight * 0.22;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, chartHeight - barHeight, barWidth, barHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, complete ? completedPaint : pendingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}

class _ReviewNote extends StatelessWidget {
  const _ReviewNote();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEFF3EA),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Expanded(
                child: Text(
                    'Use the chart as a prompt. It does not judge the experiment.')),
          ],
        ),
      ),
    );
  }
}
