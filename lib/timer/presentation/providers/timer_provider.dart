import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/application/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/infrastructure/timer_settings_adapter.dart';

import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';

import 'package:pomodoro_app2/settings/infrastructure/settings_repository.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  final notifier = TimerNotifier(TimerSettingsAdapter(settingsRepository));
  
  // Watch for settings changes and update timer when they change
  ref.listen<SettingsRepository>(settingsRepositoryProvider, (_, __) {
    if (notifier.mounted) {
      notifier.checkAndUpdateSettings();
    }
  });
  
  return notifier;
}, name: 'timerProvider');
