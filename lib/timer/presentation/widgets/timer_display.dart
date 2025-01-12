import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_controls.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_label.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        TimerLabel(),
        SizedBox(height: 20),
        TimerControls(),
      ],
    );
  }
}
