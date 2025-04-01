import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/application/auto_start_timer_use_case.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_start_timer_provider.g.dart';

@Riverpod(keepAlive: true)
void autoStartTimer(Ref ref) {
  final autoStartTimerUseCase = ref.read(autoStartTimerUseCaseProvider);

  ref.listen(timerEventsProvider, (previous, next) async {
    next.whenData((event) async {
      if (event is TimerCompletedEvent) {
        // Execute the use case when the timer completes
        await autoStartTimerUseCase.execute();
      }
    });
  });
}
