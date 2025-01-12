import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    final minutes = (timerState.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (timerState.remainingSeconds % 60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$minutes:$seconds',
          style: const TextStyle(fontSize: 48),
        ),
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
