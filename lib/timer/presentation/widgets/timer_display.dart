import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timeline_bar.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_label.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timercontrols/timer_controls.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TimerLabel(),
        SizedBox(height: 20),
        TimerControls(),
        SizedBox(height: 40),
        TimelineBar(),
      ],
    );
  }
}
