import 'package:flutter/material.dart';

import 'state/habit_store.dart';
import 'ui/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PocketHabitApp());
}

class PocketHabitApp extends StatefulWidget {
  const PocketHabitApp({super.key});

  @override
  State<PocketHabitApp> createState() => _PocketHabitAppState();
}

class _PocketHabitAppState extends State<PocketHabitApp> {
  late final HabitStore _store;

  @override
  void initState() {
    super.initState();
    _store = HabitStore()..load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        return MaterialApp(
          title: 'Pocket Habit Engine',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: _store.isLoading
              ? const LoadingView()
              : _store.errorMessage != null
                  ? ErrorView(store: _store)
                  : HomeShell(store: _store),
        );
      },
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.store, super.key});

  final HabitStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.cloud_off, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                store.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: store.load,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

ThemeData buildAppTheme() {
  const ink = Color(0xFF173A35);
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3C7466),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF7F8F4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF7F8F4),
      foregroundColor: ink,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFFDDE5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Color(0xFF3C7466), width: 2),
      ),
    ),
  );
}