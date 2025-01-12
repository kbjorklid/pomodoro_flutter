import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier()
      : super(TimerState(
          timerType: TimerType.work,
          remainingSeconds: 25 * 60,
          isRunning: false,
        ));

  void toggleTimer() {
    state = state.copyWith(isRunning: !state.isRunning);
  }

  void switchTimerType() {
    final newType = state.timerType == TimerType.work
        ? TimerType.rest
        : TimerType.work;
    state = state.copyWith(
      timerType: newType,
      remainingSeconds: newType == TimerType.work ? 25 * 60 : 5 * 60,
    );
  }
}
