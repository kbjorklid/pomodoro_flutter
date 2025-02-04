import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

class ToggleTimerTypeButtons extends ConsumerWidget {
  const ToggleTimerTypeButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerStateProvider).value;
    final timerService = ref.read(timerProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimerTypeButton(
          type: TimerType.work,
          isActive: timerState?.timerType == TimerType.work,
          onPressed: () => timerService.setTimerType(TimerType.work),
        ),
        const SizedBox(width: 16),
        _TimerTypeButton(
          type: TimerType.rest,
          isActive: timerState?.timerType == TimerType.rest,
          onPressed: () => timerService.setTimerType(TimerType.rest),
        ),
      ],
    );
  }
}

class _TimerTypeButton extends StatelessWidget {
  final TimerType type;
  final bool isActive;
  final VoidCallback onPressed;

  const _TimerTypeButton({
    required this.type,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green : null,
      ),
      onPressed: () {
        if (!isActive) {
          onPressed();
        }
      },
      child: Text(type == TimerType.work ? 'Work' : 'Rest'),
    );
  }
}
