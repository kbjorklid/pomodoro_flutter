import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pomodoro_app2/timer/domain/timer_type.dart';

part 'timer_state.freezed.dart';

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerType timerType,
    required int remainingSeconds,
    required bool isRunning,
  }) = _TimerState;
}
