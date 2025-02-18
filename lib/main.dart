import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app2/core/presentation/app_theme.dart';
import 'package:pomodoro_app2/core/presentation/providers/common_providers.dart';
import 'package:pomodoro_app2/navigation_view.dart';
import 'package:pomodoro_app2/session_saver_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// Provider to initialize all app-level services
@riverpod
void appInitializer(Ref ref) {
  print('AppInitializer running');
  ref.watch(sessionSaverProvider);
  print('Session saver initialized');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final scope = ProviderScope(
    child: Consumer(
      builder: (context, ref, child) {
        // Initialize app-level services
        ref.watch(appInitializerProvider);
        return const MyApp();
      },
    ),
  );

  runApp(scope);
}

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkForDailyReset(ref);
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