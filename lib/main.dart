import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/navigation_view.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

void main() async {
  await Hive.initFlutter();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Provider to initialize session saving
final _sessionSaverProvider = Provider<void>((ref) {
  final timerService = ref.read(timerProvider);
  final repository = ref.read(timerSessionRepositoryProvider);

  timerService.addSessionListener((session) async {
    await repository.save(session);
  });

  ref.onDispose(() async {
    timerService.removeSessionListener((session) async {});
  });
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize session saver
    ref.read(_sessionSaverProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    _finalizeAndSaveSessionIfRunning();
    return super.didRequestAppExit();
  }

  void _finalizeAndSaveSessionIfRunning() {
    final timerService = ref.read(timerProvider);
    final repository = ref.read(timerSessionRepositoryProvider);

    final session = timerService.finalizeSessionIfStarted();
    if (session != null) {
      repository.save(session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          secondary: Colors.teal,
          tertiary: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const NavigationView(),
    );
  }
}
