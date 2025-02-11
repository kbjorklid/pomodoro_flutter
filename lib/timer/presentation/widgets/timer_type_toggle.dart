import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/core/presentation/colors.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

@immutable
class _TimerTypeToggleState {
  final TimerState timerState;
  final Set<TimerType> enabledTypes;

  const _TimerTypeToggleState({
    required this.timerState,
    required this.enabledTypes,
  });
}

class ToggleTimerTypeButtons extends ConsumerWidget {
  const ToggleTimerTypeButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the timerStateProvider to get the TimerState
    final timerState = ref.watch(timerStateProvider);

    // Read the timerProvider to access timerService methods
    final timerService = ref.read(timerProvider);

    // Determine the enabled TimerTypes based on the timer state
    final Set<TimerType> enabledTypes = _getEnabledTimerTypes(timerState);

    return SegmentedButton<TimerType>(
      segments: [
        ButtonSegment<TimerType>(
          value: TimerType.work,
          label: const Text('Work'),
          icon: const Icon(Icons.work),
          enabled: enabledTypes.contains(TimerType.work),
        ),
        ButtonSegment<TimerType>(
          value: TimerType.shortRest,
          label: const Text('Short Rest'),
          icon: const Icon(Icons.coffee_maker),
          enabled: enabledTypes.contains(TimerType.shortRest),
        ),
        ButtonSegment<TimerType>(
          value: TimerType.longRest,
          label: const Text('Long Rest'),
          icon: const Icon(Icons.local_cafe),
          enabled: enabledTypes.contains(TimerType.longRest),
        ),
      ],
      selected: {timerState.timerType},
      onSelectionChanged: (Set<TimerType> newSelection) {
        timerService.setTimerType(newSelection.first);
      },
      style: ButtonStyle(
        backgroundColor: _colorSelect(_timerTypeColor(timerState.timerType)),
        foregroundColor: _colorSelect(Colors.white),
        iconColor: _colorSelect(Colors.white),
      ),
    );
  }

  // Helper function to determine enabled timer types
  Set<TimerType> _getEnabledTimerTypes(TimerState timerState) {
    final Set<TimerType> enabledTypes = {};
    if (timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused) {
      enabledTypes.add(timerState.timerType);
      enabledTypes.add(TimerType.work);
    } else {
      enabledTypes.addAll(TimerType.values);
    }
    return enabledTypes;
  }

  // Helper function to determine timer type color
  Color _timerTypeColor(TimerType currentType) {
    switch (currentType) {
      case TimerType.work:
        return AppColors.work;
      case TimerType.shortRest:
      case TimerType.longRest:
        return AppColors.rest;
    }
  }

  // Helper function to select color based on widget state
  WidgetStateProperty<Color?> _colorSelect(Color? selected,
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