
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

final timerTypeSwitchProvider = FutureProvider<bool>((ref) async {
  final timerState = await ref.watch(timerStateProvider.future);
  final settings = ref.read(settingsRepositoryProvider);

  final currentType = timerState.timerType;
  final isTimerActive = timerState.status == TimerStatus.running ||
      timerState.status == TimerStatus.paused;

  if (currentType == TimerType.work && isTimerActive) {
    return true;
  }

  if (!isTimerActive) {
    return false;
  }

  if (currentType == TimerType.shortRest) {
    final longRestDuration = await settings.getLongRestDuration();
    return timerState.remainingTime >= longRestDuration;
  } else if (currentType == TimerType.longRest) {
    final shortRestDuration = await settings.getShortRestDuration(); // Note: fixed this from getLongRestDuration
    return timerState.remainingTime >= shortRestDuration;
  }

  return false;
});