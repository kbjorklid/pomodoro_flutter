import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/daily_goal/presentation/daily_goal_widgets.dart';
import 'package:pomodoro_app2/daily_goal/presentation/providers/daily_goal_providers.dart';

class DailyGoalDisplay extends ConsumerWidget {
  const DailyGoalDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(dailyPomodoroGoalProvider);
    final todaysCountAsync = ref.watch(todaysPomodoroCountProvider);

    return goalAsync.when(
      data: (goalCount) {
        if (goalCount == null || goalCount <= 0) {
          return const SizedBox.shrink();
        }

        return todaysCountAsync.whenOrNull(
              data: (achievedCount) => PomodoroProgressDisplay(
                goalCount: goalCount,
                achievedCount: achievedCount,
              ),
              // If loading, reuse the previous data if available
              loading: () => todaysCountAsync.value != null
                  ? PomodoroProgressDisplay(
                      goalCount: goalCount,
                      achievedCount: todaysCountAsync.value!,
                    )
                  : PomodoroProgressDisplay.empty(),
              error: (error, stack) => Text('Error: $error'),
            ) ??
            PomodoroProgressDisplay.empty(); // handle null AsyncValue (rare)
      },
      loading: () => PomodoroProgressDisplay.empty(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}