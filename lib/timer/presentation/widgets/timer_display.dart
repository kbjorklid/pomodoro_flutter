import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_label.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timer_type.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const TimerLabel(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: timerNotifier.toggleTimer,
              child: Text(timerState.isRunning ? 'Pause' : 'Start'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: timerNotifier.switchTimerType,
              child: Text(timerState.timerType == TimerType.work
                  ? 'Switch to Rest'
                  : 'Switch to Work'),
            ),
          ],
        ),
      ],
    );
  }
}
