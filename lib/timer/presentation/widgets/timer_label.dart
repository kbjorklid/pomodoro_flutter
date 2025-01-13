import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

class TimerLabel extends ConsumerWidget {
  const TimerLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final minutes = (timerState.remainingTime.inMinutes).toString().padLeft(2, '0');
    final seconds = (timerState.remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: const TextStyle(fontSize: 48),
    );
  }
}
