import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';
import 'package:pomodoro_app2/timer/domain/timer_type.dart';

class SwitchTimerButton extends ConsumerWidget {
  const SwitchTimerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerService = ref.read(timerProvider.notifier);

    return ElevatedButton(
      onPressed: timerService.switchTimerType,
      child: Text(timerState.timerType == TimerType.work
          ? 'Switch to Rest'
          : 'Switch to Work'),
    );
  }
}
