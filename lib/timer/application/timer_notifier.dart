import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  TimerNotifier()
      : super(TimerState(
          timerType: TimerType.work,
          remainingSeconds: 25 * 60,
          isRunning: false,
        ));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void toggleTimer() {
    if (state.isRunning) {
      _timer?.cancel();
      state = state.copyWith(isRunning: false);
    } else {
      state = state.copyWith(isRunning: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.remainingSeconds > 0) {
          state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        } else {
          _timer?.cancel();
          state = state.copyWith(isRunning: false);
        }
      });
    }
  }

  void switchTimerType() {
    _timer?.cancel();
    final newType = state.timerType == TimerType.work
        ? TimerType.rest
        : TimerType.work;
    state = state.copyWith(
      timerType: newType,
      remainingSeconds: newType == TimerType.work ? 25 * 60 : 5 * 60,
      isRunning: false,
    );
  }
}
