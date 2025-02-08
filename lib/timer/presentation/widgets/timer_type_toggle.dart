import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/core/presentation/colors.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

class ToggleTimerTypeButtons extends ConsumerWidget {
  const ToggleTimerTypeButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerStateAsync = ref.watch(timerStateProvider);
    final timerService = ref.read(timerProvider);

    return timerStateAsync.when(
      data: (timerState) {
        final currentType = timerState.timerType;
        final isTimerActive = timerState.status == TimerStatus.running ||
            timerState.status == TimerStatus.paused;
        final disableTimerTypeSwitch =
            currentType == TimerType.work && isTimerActive;

        return SegmentedButton<TimerType>(
          segments: const [
            ButtonSegment<TimerType>(
              value: TimerType.work,
              label: Text('Work'),
              icon: Icon(Icons.work),
            ),
            ButtonSegment<TimerType>(
              value: TimerType.shortRest,
              label: Text('Short Rest'),
              icon: Icon(Icons.coffee_maker),
            ),
             ButtonSegment<TimerType>(
              value: TimerType.longRest,
              label: Text('Long Rest'),
              icon: Icon(Icons.local_cafe),
            ),
          ],
          selected: {currentType},
          onSelectionChanged: (Set<TimerType> newSelection) {
            if (!disableTimerTypeSwitch) {
              timerService.setTimerType(newSelection.first);
            }
          },
          style: ButtonStyle(
            backgroundColor: colorSelect(timerTypeColor(currentType)),
            foregroundColor: colorSelect(Colors.white),
            iconColor: colorSelect(Colors.white),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (Object error, StackTrace stackTrace) =>
          const Text('Error loading timer state'),
    );
  }

  Color timerTypeColor(TimerType currentType) {
    switch (currentType) {
      case TimerType.work:
        return AppColors.work;
      case TimerType.shortRest:
      case TimerType.longRest:
        return AppColors.rest;
    }
  }

  WidgetStateProperty<Color?> colorSelect(Color? selected,
      [Color? unselected]) {
    return WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return selected;
        }
        return unselected;
      },
    );
  }
}
