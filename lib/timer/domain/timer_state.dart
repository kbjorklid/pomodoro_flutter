import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

enum TimerType { work, rest }

@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerType timerType,
    required int remainingSeconds,
    required bool isRunning,
  }) = _TimerState;
}
