import 'package:flutter/material.dart';

import '../../core/date_tools.dart';
import '../../domain/experiment_insights.dart';
import '../../models/habit_experiment.dart';
import '../../state/habit_store.dart';

class ExperimentScreen extends StatefulWidget {
  const ExperimentScreen({required this.store, required this.experiment, super.key});

  final HabitStore store;
  final HabitExperiment experiment;

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  late final TextEditingController _noteController;
  bool _isSavingNote = false;

  @override
  void initState() {
    super.initState();
    final today = widget.store.checkInFor(widget.experiment, DateTools.today());
    _noteController = TextEditingController(text: today?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    setState(() => _isSavingNote = true);
    await widget.store.saveNote(widget.experiment, _noteController.text);
    if (mounted) setState(() => _isSavingNote = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final todayCheckIn = widget.store.checkInFor(widget.experiment, DateTools.today());
        final isComplete = todayCheckIn?.completed ?? false;
        final rate = widget.store.rateFor(widget.experiment);
        final elapsed = ExperimentInsights.elapsedDays(widget.experiment);
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.experiment.title),
            actions: <Widget>[
              IconButton(
                onPressed: () => _showExperimentInfo(context),
                icon: const Icon(Icons.info_outline),
                tooltip: 'Experiment details',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: <Widget>[
              Card(
                color: const Color(0xFFE4F0E7),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('The experiment', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 12),
                      Text(widget.experiment.statement, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 18),
                      Row(
                        children: <Widget>[
                          Expanded(child: Text('$elapsed of ${widget.experiment.targetDays} days')),
                          Text('${(rate * 100).round()}% observed'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: rate.clamp(0.0, 1.0).toDouble(),
                          minHeight: 8,
                          backgroundColor: const Color(0xFFC7DDCE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Today', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => widget.store.toggleToday(widget.experiment),
                icon: Icon(isComplete ? Icons.check_circle : Icons.radio_button_unchecked),
                label: Text(isComplete ? 'Completed today' : 'Mark today complete'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isComplete ? const Color(0xFF2F6658) : null,
                ),
              ),
              const SizedBox(height: 24),
              Text('Recent days', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Row(
                children: ExperimentInsights.daysForRange(DateTools.today(), 7)
                    .map(
                      (day) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _DayButton(
                            day: day,
                            complete: widget.store.checkInFor(widget.experiment, day)?.completed ?? false,
                            enabled: !day.isBefore(widget.experiment.startDate) && !day.isAfter(DateTools.today()),
                            onTap: () => widget.store.toggleDay(widget.experiment, day),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text('A note for later', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'What did you notice today?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _isSavingNote ? null : _saveNote,
                  icon: _isSavingNote
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save note'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExperimentInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Experiment details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Started ${DateTools.monthAndDay(widget.experiment.startDate)}'),
              const SizedBox(height: 8),
              Text('Planned length: ${widget.experiment.targetDays} days'),
              const SizedBox(height: 8),
              const Text('All records stay on this device.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.day,
    required this.complete,
    required this.enabled,
    required this.onTap,
  });

  final DateTime day;
  final bool complete;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = DateTools.key(day) == DateTools.key(DateTools.today());
    final scheme = Theme.of(context).colorScheme;
    final label = '${DateTools.shortWeekday(day)} ${day.day}, ${complete ? 'complete' : 'not complete'}';
    return Semantics(
      button: enabled,
      label: label,
      child: Material(
        color: complete ? scheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday ? scheme.primary : const Color(0xFFDDE5DD),
                width: isToday ? 2 : 1,
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  DateTools.shortWeekday(day).substring(0, 1),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: complete ? Colors.white : const Color(0xFF577069),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: complete ? Colors.white : const Color(0xFF173A35),
                      ),
                ),
                const SizedBox(height: 4),
                Icon(
                  complete ? Icons.check : Icons.remove,
                  size: 14,
                  color: complete ? Colors.white : const Color(0xFFA0AEA4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}