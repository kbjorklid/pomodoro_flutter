import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/domain/timer_settings_port.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  final TimerSettingsPort _settings;
  Timer? _timer;

  TimerNotifier(this._settings)
      : super(TimerState(
          timerType: TimerType.work,
          remainingSeconds: 25 * 60, // Default while loading
          isRunning: false,
        )) {
    _initialize();
  }

  Future<void> _initialize() async {
    final initialDuration = await _settings.workDurationSeconds;
    state = state.copyWith(remainingSeconds: initialDuration);
  }

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

  Future<void> switchTimerType() async {
    _timer?.cancel();
    final newType = state.timerType == TimerType.work
        ? TimerType.rest
        : TimerType.work;
    final duration = await (newType == TimerType.work
        ? _settings.workDurationSeconds
        : _settings.restDurationSeconds);
    state = TimerState(
      timerType: newType,
      remainingSeconds: duration,
      isRunning: false,
    );
  }

}
