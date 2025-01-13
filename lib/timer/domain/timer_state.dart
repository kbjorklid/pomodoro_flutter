import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pomodoro_app2/timer/domain/timer_type.dart';

part 'timer_state.freezed.dart';

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerType timerType,
    // Modify the type of this to duration AI!
    required Duration remainingTime,
    required bool isRunning,
  }) = _TimerState;
}
