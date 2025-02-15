import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timeline_bar.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_label.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_type_toggle.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timercontrols/timer_controls.dart';

import 'daily_goal_display.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const ToggleTimerTypeButtons(),
        const SizedBox(height: 20),
        const TimerLabel(),
        const SizedBox(height: 20),
        const TimerControls(),
        const SizedBox(height: 20),
        const TimelineBar(),
        const SizedBox(height: 5),
        const DailyGoalDisplay(),
      ],
    );
  }
}