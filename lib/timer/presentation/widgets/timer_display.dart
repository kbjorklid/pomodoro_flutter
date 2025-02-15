import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/daily_goal/presentation/daily_goal_widgets.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timeline_bar.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_label.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_type_toggle.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timercontrols/timer_controls.dart';

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
        Consumer(builder: (context, ref, _) {
          final dailyGoal =
              ref.watch(settingsRepositoryProvider).getDailyPomodoroGoal();

          return FutureBuilder<int?>(
            future: dailyGoal,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Or some other loading indicator
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final goalCount = snapshot.data;
                if (goalCount != null && goalCount > 0) {
                  final timerSessionRepository =
                      ref.read(timerSessionRepositoryProvider);
                  return FutureBuilder<int>(
                    future: timerSessionRepository
                        .getPomodoroCountForDate(DateTime.now()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final achievedCount = snapshot.data ?? 0;
                        return PomodoroProgressDisplay(
                          goalCount: goalCount,
                          achievedCount: achievedCount,
                        );
                      }
                    },
                  );
                } else {
                  return const SizedBox
                      .shrink(); // Don't display if goal is not set
                }
              }
            },
          );
        }),
        const SizedBox(height: 40),
        const TimelineBar(),
      ],
    );
  }
}
