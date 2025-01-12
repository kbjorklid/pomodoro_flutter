import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timer_type.dart';


class TimerNotifier extends StateNotifier<TimerState> {
  static final int _workDurationSeconds = 25 * 60;
  static final int _restDurationSeconds = 5 * 60;

  Timer? _timer;
  TimerNotifier()
      : super(_buildInitialState(TimerType.work));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void toggleTimer() {
    if (state.isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void _startTimer() {
    state = state.copyWith(isRunning: true);
    _startTimerTicks();
  }

  void _startTimerTicks() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _stopTimer();
      }
    });
  }

  void switchTimerType() {
    _timer?.cancel();
    final newType = state.timerType == TimerType.work
        ? TimerType.rest
        : TimerType.work;
    state = _buildInitialState(newType);
  }

  static TimerState _buildInitialState(TimerType timerType) {
    final duration = (timerType == TimerType.work) ?
        _workDurationSeconds : _restDurationSeconds;
    return TimerState(
      timerType: timerType,
      remainingSeconds: duration,
      isRunning: false,
    );
  }
}
