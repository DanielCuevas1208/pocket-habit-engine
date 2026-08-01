import 'package:flutter/material.dart';

import '../core/date_tools.dart';
import '../models/habit_experiment.dart';
import '../state/habit_store.dart';
import 'screens/experiment_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/review_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({required this.store, super.key});

  final HabitStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  Future<void> _openCreateSheet() async {
    final experiment = await showModalBottomSheet<HabitExperiment>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateExperimentSheet(),
    );
    if (experiment != null && mounted) {
      await widget.store.createExperiment(experiment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Experiment added to your journal.')),
        );
      }
    }
  }

  void _openExperiment(HabitExperiment experiment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ExperimentScreen(store: widget.store, experiment: experiment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          OverviewScreen(store: widget.store, onOpenExperiment: _openExperiment),
          ReviewScreen(store: widget.store),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openCreateSheet,
              icon: const Icon(Icons.add),
              label: const Text('New experiment'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Review'),
        ],
      ),
    );
  }
}

class CreateExperimentSheet extends StatefulWidget {
  const CreateExperimentSheet({super.key});

  @override
  State<CreateExperimentSheet> createState() => _CreateExperimentSheetState();
}

class _CreateExperimentSheetState extends State<CreateExperimentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cueController = TextEditingController();
  final _actionController = TextEditingController();
  final _daysController = TextEditingController(text: '14');

  @override
  void dispose() {
    _titleController.dispose();
    _cueController.dispose();
    _actionController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final targetDays = int.tryParse(_daysController.text.trim()) ?? 14;
    Navigator.of(context).pop(
      HabitExperiment(
        title: _titleController.text.trim(),
        cue: _cueController.text.trim(),
        action: _actionController.text.trim(),
        startDate: DateTools.today(),
        targetDays: targetDays,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8F4),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFFB9C7BA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Start a small experiment', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Name the routine, its cue, and the smallest useful action.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Experiment name', hintText: 'Evening reset'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Add a name.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cueController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'When I...', hintText: 'finish dinner'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Add a cue.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _actionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'I will...', hintText: 'put my phone away'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Add an action.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Experiment length', suffixText: 'days'),
                  validator: (value) {
                    final days = int.tryParse(value?.trim() ?? '');
                    return days == null || days < 1 || days > 90 ? 'Use 1 to 90 days.' : null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Begin experiment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}