import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
        final state = event.timerState;
        final endedSession = EndedTimerSession(
          sessionType: state.timerType,
          startedAt: state.startedAt!,
          endedAt: event.endedAt,
          pauses: state.pauses,
          totalDuration: state.timerDuration,
        );

        await repository.save(endedSession);
      }
    });
  });
}