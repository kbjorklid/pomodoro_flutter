import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/core/presentation/colors.dart';
import 'package:pomodoro_app2/timer/application/get_timer_types_allowed_to_switch_to_use_case.dart';
import 'package:pomodoro_app2/timer/application/set_timer_type_use_case.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';

class ToggleTimerTypeButtons extends ConsumerWidget {
  const ToggleTimerTypeButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AsyncValueWidget(
      value: ref.watch(timerTypesAllowedToSwitchToProvider),
      data: (enabledTypes) => _TimerStateWidget(enabledTypes: enabledTypes),
      loadingWidget: const _TimerTypeSelector(
        enabledTypes: {},
        selectedType: TimerType.work,
      ),
    );
  }
}

class _TimerStateWidget extends ConsumerWidget {
  final Set<TimerType> enabledTypes;

  const _TimerStateWidget({required this.enabledTypes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AsyncValueWidget(
      value: ref.watch(pomodoroTimerProvider),
      data: (timerState) => _TimerTypeSelector(
        enabledTypes: enabledTypes,
        selectedType: timerState.timerType,
      ),
      loadingWidget: _TimerTypeSelector(
        enabledTypes: {},
        selectedType: TimerType.work,
      ),
    );
  }
}

class _TimerTypeSelector extends ConsumerWidget {
  final Set<TimerType> enabledTypes;
  final TimerType selectedType;

  const _TimerTypeSelector({
    required this.enabledTypes,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<TimerType>(
      segments: _buildSegments(),
      selected: {selectedType},
      onSelectionChanged: (Set<TimerType> newSelection) async {
        final selection = newSelection.first;
        await ref.read(setTimerTypeUseCaseProvider).execute(selection);
      },
      style: ButtonStyle(
        backgroundColor: _colorSelect(_timerTypeColor(selectedType)),
        foregroundColor: _colorSelect(Colors.white),
        iconColor: _colorSelect(Colors.white),
      ),
    );
  }

  List<ButtonSegment<TimerType>> _buildSegments() => [
        _buildSegment(
          TimerType.work,
          'Work',
          const Icon(Icons.work),
        ),
        _buildSegment(
          TimerType.shortRest,
          'Short Rest',
          const Icon(Icons.coffee_maker),
        ),
        _buildSegment(
          TimerType.longRest,
          'Long Rest',
          const Icon(Icons.local_cafe),
        ),
      ];

  ButtonSegment<TimerType> _buildSegment(TimerType type,
      String label,
      Icon icon,) =>
      ButtonSegment<TimerType>(
        value: type,
        label: Text(label),
        icon: icon,
        enabled: enabledTypes.contains(type),
      );

  Color _timerTypeColor(TimerType currentType) {
    switch (currentType) {
      case TimerType.work:
        return AppColors.work;
      case TimerType.shortRest:
      case TimerType.longRest:
        return AppColors.rest;
    }
  }

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

class _AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget loadingWidget;

  const _AsyncValueWidget({
    required this.value,
    required this.data,
    required this.loadingWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (error, _) => Text('error: $error'),
      loading: () => loadingWidget,
    );
  }
}