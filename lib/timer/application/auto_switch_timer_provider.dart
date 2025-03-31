import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/application/auto_switch_timer_type_use_case.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_switch_timer_provider.g.dart';

@Riverpod(keepAlive: true)
void autoSwitchTimer(Ref ref) {
  final autoSwitchTimerTypeUseCase =
      ref.read(autoSwitchTimerTypeUseCaseProvider);

  ref.listen(timerEventsProvider, (previous, next) async {
    next.whenData((event) async {
      if (event is TimerCompletedEvent) {
        await autoSwitchTimerTypeUseCase.execute();
      }
    });
  });
}
