import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/start_pause_button.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/switch_timer_button.dart';

class TimerControls extends ConsumerWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        StartPauseButton(),
        SizedBox(width: 20),
        SwitchTimerButton(),
      ],
    );
  }
}
