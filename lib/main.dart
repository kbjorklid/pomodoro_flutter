import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app2/core/presentation/providers/common_providers.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/navigation_view.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final scope = ProviderScope(
    child: MyApp(),
  );

  runApp(scope);
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
    ref.read(_sessionSaverProvider);
    _initializeDailyResetTimer(ref);
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

  Future<void> _initializeDailyResetTimer(WidgetRef ref) async {
    // Check if the day has changed since the last app open
    final kvRepo = ref.read(keyValueStoreProvider);
    final DateTime? lastCheckedDate =
        await kvRepo.get<DateTime>('lastCheckedDate');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Midnight today

    if (lastCheckedDate == null || lastCheckedDate.isBefore(today)) {
      // Day has changed, set dailyResetProvider to true
      ref.read(dailyResetProvider.notifier).state++;
      await kvRepo.save<DateTime>('lastCheckedDate', today);
    }

    // Start a timer that checks every minute if the day has changed
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastCheckedDate == null || lastCheckedDate.isBefore(today)) {
        ref.read(dailyResetProvider.notifier).state++;
        await kvRepo.save<DateTime>('lastCheckedDate', today);
      }
    });
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
