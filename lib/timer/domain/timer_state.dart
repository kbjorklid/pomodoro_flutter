import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';

part 'timer_state.freezed.dart';

enum TimerStatus {
  running,
  paused,
  ended,
  notStarted,
}

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerType timerType,
    required Duration totalTime,
    required Duration remainingTime,
    required TimerStatus status,
  }) = _TimerState;
}
