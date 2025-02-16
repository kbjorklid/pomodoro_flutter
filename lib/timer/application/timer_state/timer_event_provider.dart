import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
Stream<TimerEvent> timerEvents(Ref ref) {
  return ref.watch(pomodoroTimerProvider.notifier).events;
}