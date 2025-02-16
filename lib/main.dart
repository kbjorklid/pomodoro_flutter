import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app2/core/presentation/app_theme.dart';
import 'package:pomodoro_app2/core/presentation/providers/common_providers.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/navigation_view.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
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

  void saveSession(EndedTimerSession session) async {
    await repository.save(session);
  }

  timerService.addSessionListener(saveSession);

  ref.onDispose(() async {
    timerService.removeSessionListener(saveSession);
  });
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  static const _dayChangeCheckInterval = Duration(minutes: 1);
  static const _lastCheckedDateKey = 'lastCheckedDate';

  Timer? _dailyResetTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(_sessionSaverProvider);
    _initializeDailyResetTimer(ref);
    _startDailyResetTimer(); // Start the timer after initialization
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dailyResetTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    _finalizeAndSaveSessionIfRunning();
    return super.didRequestAppExit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkForDailyReset(ref);
    }
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
    final kvRepo = ref.read(keyValueStoreProvider);
    final DateTime? lastCheckedDate =
        await kvRepo.get<DateTime>(_lastCheckedDateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastCheckedDate == null || lastCheckedDate.isBefore(today)) {
      ref.read(dailyResetProvider.notifier).state++;
      await kvRepo.save<DateTime>(_lastCheckedDateKey, today);
    }
  }

  void _startDailyResetTimer() {
    // Cancel the existing timer if any
    _dailyResetTimer?.cancel();
    // Start a timer that checks every minute if the day has changed
    _dailyResetTimer = Timer.periodic(_dayChangeCheckInterval, (timer) async {
      await _checkForDailyReset(ref);
    });
  }

  Future<void> _checkForDailyReset(WidgetRef ref) async {
    final kvRepo = ref.read(keyValueStoreProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime? lastCheckedDate =
        await kvRepo.get<DateTime>(_lastCheckedDateKey);
    if (lastCheckedDate == null || lastCheckedDate.isBefore(today)) {
      ref.read(dailyResetProvider.notifier).state++;
      await kvRepo.save<DateTime>(_lastCheckedDateKey, today);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: AppTheme.light,
      home: const NavigationView(),
    );
  }
}