import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/application/timer_service.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/infrastructure/timer_settings_adapter.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/settings/infrastructure/settings_repository.dart';

final timerProvider = StateNotifierProvider<TimerService, TimerState>((ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  final timerService = TimerService(TimerSettingsAdapter(settingsRepository));

  // Watch for settings changes and update timer when they change
  ref.listen<SettingsRepository>(settingsRepositoryProvider, (_, __) {
    if (timerService.mounted) {
      timerService.checkAndUpdateSettings();
    }
  });

  return timerService;
}, name: 'timerProvider');
