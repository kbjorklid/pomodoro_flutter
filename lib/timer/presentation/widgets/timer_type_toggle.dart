import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/core/presentation/colors.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
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

final _timerTypeToggleProvider = NotifierProvider.autoDispose<
    _TimerTypeToggleNotifier, AsyncValue<_TimerTypeToggleState>>(() {
  return _TimerTypeToggleNotifier();
});

class _TimerTypeToggleNotifier
    extends AutoDisposeNotifier<AsyncValue<_TimerTypeToggleState>> {
  @override
  AsyncValue<_TimerTypeToggleState> build() {
    // Start with loading state
    state = const AsyncValue.loading();

    // Listen to timer state changes
    ref.listen(timerStateProvider, (previous, next) async {
      next.whenData((timerState) async {
        final settings = ref.read(settingsRepositoryProvider);

        final currentType = timerState.timerType;
        final isTimerActive = timerState.status == TimerStatus.running ||
            timerState.status == TimerStatus.paused;

        final Set<TimerType> enabledTypes = {};
        if (isTimerActive) {
          enabledTypes.add(currentType);
          enabledTypes.add(TimerType.work);
          if (currentType == TimerType.shortRest &&
              timerState.elapsedTime < await settings.getLongRestDuration()) {
            enabledTypes.add(TimerType.longRest);
          }
          if (currentType == TimerType.longRest &&
              timerState.elapsedTime < await settings.getShortRestDuration()) {
            enabledTypes.add(TimerType.shortRest);
          }
        } else {
          enabledTypes.addAll(TimerType.values);
        }

        state = AsyncValue.data(_TimerTypeToggleState(
          timerState: timerState,
          enabledTypes: enabledTypes,
        ));
      });
    });

    // Return initial loading state
    return const AsyncValue.loading();
  }
}

class ToggleTimerTypeButtons extends ConsumerWidget {
  const ToggleTimerTypeButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggleStateAsync = ref.watch(_timerTypeToggleProvider);
    final timerService = ref.read(timerProvider);

    return toggleStateAsync.when(
      data: (state) => SegmentedButton<TimerType>(
        segments: [
          ButtonSegment<TimerType>(
              value: TimerType.work,
              label: Text('Work'),
              icon: Icon(Icons.work),
              enabled: state.enabledTypes.contains(TimerType.work)),
          ButtonSegment<TimerType>(
              value: TimerType.shortRest,
              label: Text('Short Rest'),
              icon: Icon(Icons.coffee_maker),
              enabled: state.enabledTypes.contains(TimerType.shortRest)),
          ButtonSegment<TimerType>(
              value: TimerType.longRest,
              label: Text('Long Rest'),
              icon: Icon(Icons.local_cafe),
              enabled: state.enabledTypes.contains(TimerType.longRest)),
        ],
        selected: {state.timerState.timerType},
        onSelectionChanged: (Set<TimerType> newSelection) {
          timerService.setTimerType(newSelection.first);
        },
        style: ButtonStyle(
          backgroundColor:
              colorSelect(timerTypeColor(state.timerState.timerType)),
          foregroundColor: colorSelect(Colors.white),
          iconColor: colorSelect(Colors.white),
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading timer state'),
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