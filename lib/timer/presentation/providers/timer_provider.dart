import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_history_updated_event.dart';
import 'package:pomodoro_app2/history/domain/timer_session_query.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/sound/presentation/providers/sound_player_provider.dart';
import 'package:pomodoro_app2/timer/application/play_timer_end_sound_use_case.dart';
import 'package:pomodoro_app2/timer/application/timer_service.dart';
import 'package:pomodoro_app2/timer/application/toggle_timer_use_case.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timersession/completion_status.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

TimerService? _timerService;

final timerProvider = Provider<TimerService>((ref) {
  _timerService ??= TimerService(
    ref.watch(settingsRepositoryProvider),
    PlayTimerEndSoundUseCase(
      ref.watch(soundPlayerProvider),
      ref.watch(settingsRepositoryProvider),
    ),
  );
  return _timerService!;
});

final toggleTimerUseCaseProvider = Provider<ToggleTimerUseCase>((ref) {
  return ToggleTimerUseCase(ref.watch(timerProvider));
});

final todaySessionsProvider = FutureProvider<List<TimerSession>>((ref) {
  final now = DateTime.now();
  final startTime = DateTime(now.year, now.month, now.day, 8);
  final endTime = DateTime(now.year, now.month, now.day, 23);

  return ref.read(timerSessionRepositoryProvider).query(TimerSessionQuery(
        start: startTime,
        end: endTime,
        completionStatus: CompletionStatus.any,
      ));
});

final timerHistoryUpdateProvider = StreamProvider.autoDispose<void>((ref) {
  return DomainEventBus.of<TimerHistoryUpdatedEvent>();
});

final timerStateProvider =
    StateNotifierProvider<TimerStateNotifier, TimerState>((ref) {
  return TimerStateNotifier(ref);
});

class TimerStateNotifier extends StateNotifier<TimerState> {
  final Ref ref;
  late final timerService = ref.read(timerProvider); // Use read here, not watch
  // This code is only executed once.

  TimerStateNotifier(this.ref) : super(TimerState.initial()) {
    // Call initial state.
    _initialize();
  }

  Future<void> _initialize() async {
    // This function is called only on initialization
    timerService.addStateListener(_stateListener);

    // Perform initial refresh of duration and set initial state only once
    await _refreshDuration();
    state = timerService.state;
  }

  Future<void> _refreshDuration() async {
    await timerService.refreshDuration();
  }

  void _stateListener(TimerState newState) {
    state = newState; // Update state when timerService emits a new state
  }

  @override
  void dispose() {
    timerService.removeStateListener(_stateListener);
    super.dispose();
  }
}
