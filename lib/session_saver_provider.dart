import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'timer/domain/timer_state.dart';

part 'session_saver_provider.g.dart';

/// Provider that listens to timer events and saves completed sessions to the repository
// In session_saver_provider.dart
@Riverpod(keepAlive: true)
void sessionSaver(Ref ref) {
  final timer = ref.watch(pomodoroTimerProvider.notifier);
  final repository = ref.read(timerSessionRepositoryProvider);

  ref.listen(timerEventsProvider, (previous, next) async {
    // Handle the AsyncValue wrapper
    next.whenData((event) async {
      if (event is TimerEndedEvent) {
        final currentSession = timer.getCurrentSession();
        final endedSession = EndedTimerSession(
          sessionType: currentSession.sessionType,
          startedAt: currentSession.startedAt,
          endedAt: event.endedAt,
          pauses: currentSession.pauses,
          totalDuration: currentSession.totalDuration,
        );

        await repository.save(endedSession);
      }
    });
  });
}

DateTime _getEndTime(TimerState? timerState) {
  final DateTime now = DateTime.now();
  if (timerState == null) {
    return now;
  }
  final estimatedEndTime = timerState.estimatedEndTime;
  // In case the device is suspended, this sets timer end to where it
  // was supposed to end.
  if (estimatedEndTime != null && estimatedEndTime.isBefore(now)) {
    return estimatedEndTime;
  }
  return now;
}