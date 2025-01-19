import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_service.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';

TimerService? _timerService;

final timerProvider = Provider<TimerService>((ref) {
  _timerService ??= TimerService(ref.watch(settingsRepositoryProvider));
  return _timerService!;
});

final timerStateProvider = StreamProvider<TimerState>((ref) {
  final timerService = ref.watch(timerProvider);
  final controller = StreamController<TimerState>();

  void listener(TimerState state) {
    controller.add(state);
  }

  timerService.addListener(listener);
  ref.onDispose(() {
    timerService.removeListener(listener);
    controller.close();
  });

  controller.add(timerService.state);

  return controller.stream;
});
