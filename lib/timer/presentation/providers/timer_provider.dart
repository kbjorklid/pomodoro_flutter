import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/application/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
