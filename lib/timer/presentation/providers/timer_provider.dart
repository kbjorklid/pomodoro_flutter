import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final startTime = DateTime(now.year, now.month, now.day, 16);
  final endTime = DateTime(now.year, now.month, now.day, 22);

  return ref.read(timerSessionRepositoryProvider).query(TimerSessionQuery(
        start: startTime,
        end: endTime,
        completionStatus: CompletionStatus.any,
      ));
});

final timerStateProvider = StreamProvider<TimerState>((ref) {
  final timerService = ref.watch(timerProvider);
  final controller = StreamController<TimerState>();

  void listener(TimerState state) {
    controller.add(state);
  }

  timerService.addStateListener(listener);
  ref.onDispose(() {
    timerService.removeStateListener(listener);
    controller.close();
  });

  controller.add(timerService.state);

  return controller.stream;
});
