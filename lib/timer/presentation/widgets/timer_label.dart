import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

class TimerLabel extends ConsumerWidget {
  const TimerLabel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final remaining = timerState.remainingTime;
    final total = timerState.totalTime;
    final progress = total.inSeconds > 0 ? remaining.inSeconds / total.inSeconds : 0.0;
    final minutes = (remaining.inMinutes).toString();
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(value: progress, strokeWidth: 8),
          ),
          Text('$minutes:$seconds', style: const TextStyle(fontSize: 48)),
        ],
      ),
    );
  }
}
