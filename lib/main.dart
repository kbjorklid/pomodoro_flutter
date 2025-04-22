import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app2/core/presentation/app_theme.dart';
import 'package:pomodoro_app2/core/presentation/providers/common_providers.dart';
import 'package:pomodoro_app2/history/presentation/providers/session_saver_provider.dart';
import 'package:pomodoro_app2/navigation_view.dart';
import 'package:pomodoro_app2/settings/domain/app_theme_mode.dart'; // Import theme mode
import 'package:pomodoro_app2/settings/presentation/providers/theme_providers.dart'; // Import theme provider
import 'package:pomodoro_app2/sound/presentation/providers/session_end_sound_provider.dart';
import 'package:pomodoro_app2/timer/application/auto_start_timer_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomodoro_app2/timer/application/auto_switch_timer_provider.dart';
import 'package:pomodoro_app2/task_list/infrastructure/task_list_repository_impl.dart';
import 'package:pomodoro_app2/task_list/infrastructure/task_list_dtos.dart';
import 'package:pomodoro_app2/task_list/presentation/providers/task_list_providers.dart';

part 'main.g.dart';

// Provider to initialize all app-level services
@riverpod
void appInitializer(Ref ref) {
  ref.watch(sessionSaverProvider);
  ref.watch(sessionEndSoundNotifierProvider);
  ref.watch(autoSwitchTimerProvider); // Watch auto-switch first
  ref.watch(autoStartTimerProvider);
  ref.watch(themeModeNotifierProvider); // Initialize theme provider
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TaskListDtoAdapter());
  Hive.registerAdapter(TaskDtoAdapter());

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          // Open Hive box and override the TaskListRepository provider
          final taskListBoxAsyncValue = ref.watch(taskListBoxProvider);

          return taskListBoxAsyncValue.when(
            data: (taskListBox) {
              return ProviderScope(
                overrides: [
                  taskListRepositoryProvider.overrideWithValue(
                    TaskListRepositoryImpl(taskListBox),
                  ),
                ],
                child: const MyApp(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  static const _dayChangeCheckInterval = Duration(minutes: 1);
  static const _lastCheckedDateKey = 'lastCheckedDate';

  Timer? _dailyResetTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDailyResetTimer(ref);
    _startDailyResetTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dailyResetTimer?.cancel();
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

  // Helper to map AppThemeMode to Flutter's ThemeMode
  ThemeMode _mapAppThemeModeToThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme provider state
    final themeModeAsyncValue = ref.watch(themeModeNotifierProvider);

    return themeModeAsyncValue.when(
      data: (themeMode) => MaterialApp(
        title: 'Pomodoro Timer',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _mapAppThemeModeToThemeMode(themeMode),
        home: const NavigationView(),
      ),
      // Show loading indicator while theme is loading
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      // Show error message if theme loading fails
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error loading theme: $err')),
        ),
      ),
    );
  }
}
