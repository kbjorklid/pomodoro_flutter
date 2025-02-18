import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_saver_provider.g.dart';

/// Provider that listens to timer events and saves completed sessions to the repository
@Riverpod(keepAlive: true)
void sessionSaver(Ref ref) {
  final timer = ref.watch(pomodoroTimerProvider.notifier);
  final repository = ref.read(timerSessionRepositoryProvider);

  ref.listen(timerEventsProvider, (previous, next) async {
    if (next is TimerStoppedEvent || next is TimerCompletedEvent) {
      // Get the current session and create an EndedTimerSession
      final currentSession = timer.getCurrentSession();
      final now = DateTime.now();

      final endedSession = EndedTimerSession(
        sessionType: currentSession.sessionType,
        startedAt: currentSession.startedAt,
        endedAt: now,
        pauses: currentSession.pauses,
        totalDuration: currentSession.totalDuration,
      );

      await repository.save(endedSession);
    }
  });
}