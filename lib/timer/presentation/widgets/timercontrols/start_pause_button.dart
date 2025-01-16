import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

class StartPauseButton extends ConsumerWidget {
  const StartPauseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerService = ref.read(timerProvider.notifier);

    return ElevatedButton(
      onPressed: timerService.toggleTimer,
      child: Text(timerState.isRunning ? 'Pause' : 'Start'),
    );
  }
}
