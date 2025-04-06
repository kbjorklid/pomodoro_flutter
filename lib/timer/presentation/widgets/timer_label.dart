import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/time_formatter.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/core/presentation/colors.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
class TimerLabel extends ConsumerWidget {
  const TimerLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStateAsync = ref.watch(pomodoroTimerProvider);

    return timerStateAsync.when(
        data: (timerState) => _buildComponent(timerState, context),
        error: (error, _) => _buildTextReplacement("Error: $error"),
        loading: () => _buildTextReplacement("Loading..."));
  }

  Widget _buildTextReplacement(String message) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Center(
        child: Text(message, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget _buildComponent(TimerState timerState, BuildContext context) {
    final DateTime now = DateTime.now();
    final remaining = timerState.getRemainingTime(now);
    final total = timerState.timerDuration;
    final progress =
        total.inSeconds > 0 ? remaining.inSeconds / total.inSeconds : 0.0;
    final timeLabel = TimeFormatter.toMinutesAndSeconds(remaining);

    final bool paused = timerState.status == TimerStatus.paused;

    final Color color = _getColor(timerState.timerType, paused);

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              color: _getProgressIndicatorBackgroundColor(context),
            ),
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              color: color,
            ),
          ),
          Text(timeLabel, style: const TextStyle(fontSize: 48)),
        ],
      ),
    );
  }

  // Helper function to determine the color based on timer type and paused state
  Color _getColor(TimerType timerType, bool paused) {
    switch (timerType) {
      case TimerType.work:
        return paused ? AppColors.workPaused : AppColors.work;
      case TimerType.shortRest:
      case TimerType.longRest:
        return paused ? AppColors.restPaused : AppColors.rest;
    }
  }
  Color _getProgressIndicatorBackgroundColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.grey[800]!;
    } else {
      return Colors.grey[300]!;
    }
  }
}
