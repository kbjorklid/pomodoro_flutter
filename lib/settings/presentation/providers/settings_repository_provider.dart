import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/settings/domain/timer_durations.dart';
import 'package:pomodoro_app2/settings/infrastructure/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepositoryPort>((ref) {
  return SettingsRepository();
});

final timerDurationsStreamProvider = StreamProvider<TimerDurations>((ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  return (settingsRepository as SettingsRepository).timerDurationsChangedStream;
});

final timerDurationsProvider = FutureProvider<TimerDurations>((ref) {
  return ref.watch(settingsRepositoryProvider).getTimerDurations();
});
