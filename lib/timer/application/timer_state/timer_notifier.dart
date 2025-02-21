// timer_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/settings/domain/timer_durations.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_notifier.g.dart';
sealed class TimerEvent {
  final TimerState timerState;

  const TimerEvent({required this.timerState});
}

sealed class TimerRuntimeEvent extends TimerEvent {
  final Duration remainingTime;
  final Duration elapsedTime;

  const TimerRuntimeEvent(
      {required super.timerState,
      required this.remainingTime,
      required this.elapsedTime});
}

class TimerTickEvent extends TimerRuntimeEvent {
  const TimerTickEvent(
      {required super.timerState,
      required super.remainingTime,
      required super.elapsedTime});
}

class TimerStartedEvent extends TimerRuntimeEvent {
  const TimerStartedEvent(
      {required super.timerState,
      required super.remainingTime,
      super.elapsedTime = Duration.zero});
}

class TimerPausedEvent extends TimerRuntimeEvent {
  const TimerPausedEvent(
      {required super.timerState,
      required super.remainingTime,
      required super.elapsedTime});
}

class TimerResumedEvent extends TimerRuntimeEvent {
  const TimerResumedEvent(
      {required super.timerState,
      required super.remainingTime,
      required super.elapsedTime});
}

class TimerCompletedEvent extends TimerRuntimeEvent {
  const TimerCompletedEvent(
      {required super.timerState,
      super.remainingTime = Duration.zero,
      required super.elapsedTime});
}

class TimerStoppedEvent extends TimerRuntimeEvent {
  const TimerStoppedEvent(
      {required super.timerState,
      required super.remainingTime,
      required super.elapsedTime});
}

class TimerResetEvent extends TimerEvent {
  const TimerResetEvent({required super.timerState});
}

@riverpod
class PomodoroTimer extends _$PomodoroTimer {
  Timer? _timer;
  StreamController<TimerEvent>? _eventController;
  late SettingsRepositoryPort _settingsRepository;
  late TimerDurations _durations;
  Duration? _targetDurationOfStartedTimer;

  @override
  FutureOr<TimerState> build() async {
    _eventController = StreamController<TimerEvent>.broadcast();
    ref.onDispose(() {
      _timer?.cancel();
      _eventController?.close();
    });

    _settingsRepository = ref.read(settingsRepositoryProvider);
    _durations = await _settingsRepository.getTimerDurations();

    ref.listen(timerDurationsStreamProvider, (previous, next) {
      next.whenData((value) async {
        _durations = await _settingsRepository.getTimerDurations();
        if (state.value?.status == TimerStatus.notStarted) {
          resetTimer();
        }
      });
    });

    return TimerState.initial(
        TimerType.work, _durations.getDuration(TimerType.work));
  }

  Stream<TimerEvent> get events => _eventController!.stream;

  void startTimer([TimerType? timerType]) async {
    if (state.value?.status == TimerStatus.running) {
      return;
    }
    timerType ??= getCurrentTimerType();

    _timer?.cancel();

    final now = DateTime.now();
    final Duration duration = _durations.getDuration(timerType);
    _targetDurationOfStartedTimer = duration;

    final timerState = TimerState(
      timerType: timerType,
      status: TimerStatus.running,
      timerDuration: duration,
      startedAt: now,
      pauses: [],
      pausedAt: null,
    );

    state = AsyncData(timerState);

    _eventController?.add(TimerStartedEvent(
        timerState: timerState,
        remainingTime: duration,
        elapsedTime: Duration.zero));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _handleTick();
    });
  }

  void resetTimer([TimerType? timerType]) {
    timerType ??= getCurrentTimerType();
    _timer?.cancel();
    final duration = _durations.getDuration(timerType);
    state = AsyncData(TimerState(
      timerType: timerType,
      status: TimerStatus.notStarted,
      timerDuration: duration,
      startedAt: null,
      pauses: [],
      pausedAt: null,
    ));
    _eventController?.add(TimerResetEvent(timerState: state.requireValue));
  }

  void pauseTimer() {
    if (state.value?.status != TimerStatus.running) {
      return;
    }

    _timer?.cancel();
    final now = DateTime.now();

    final timerState = TimerState(
      timerType: state.value!.timerType,
      status: TimerStatus.paused,
      timerDuration: state.value!.timerDuration,
      startedAt: state.value!.startedAt,
      pauses: [...state.value!.pauses],
      pausedAt: now,
    );

    state = AsyncData(timerState);

    _eventController?.add(TimerPausedEvent(
        timerState: timerState,
        remainingTime: timerState.getRemainingTime(now),
        elapsedTime: timerState.getElapsedTimeIgnoringPauses(now)));
  }

  void resumeTimer() {
    if (state.value?.status != TimerStatus.paused) {
      return;
    }

    final now = DateTime.now();

    final oldState = state.value!;
    final newState = TimerState(
      timerType: oldState.timerType,
      status: TimerStatus.running,
      timerDuration: oldState.timerDuration,
      startedAt: oldState.startedAt,
      pauses: [
        ...oldState.pauses,
        PauseRecord(
          pausedAt: oldState.pausedAt!,
          resumedAt: now,
        ),
      ],
      pausedAt: null,
    );

    state = AsyncData(newState);

    _eventController?.add(TimerResumedEvent(
        timerState: newState,
        remainingTime: newState.getRemainingTime(now),
        elapsedTime: newState.getElapsedTimeIgnoringPauses(now)));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _handleTick();
    });
  }

  void stopTimer() {
    if (state.value?.status == TimerStatus.notStarted) {
      return;
    }

    _timer?.cancel();

    final now = DateTime.now();
    final currentState = state.value!;
    List<PauseRecord> finalPauses = [...currentState.pauses];

    if (currentState.pausedAt != null) {
      finalPauses.add(PauseRecord(
        pausedAt: currentState.pausedAt!,
        resumedAt: now,
      ));
    }

    final newState = TimerState(
      timerType: currentState.timerType,
      status: TimerStatus.ended,
      timerDuration: currentState.timerDuration,
      startedAt: currentState.startedAt,
      pauses: finalPauses,
      pausedAt: null,
    );

    state = AsyncData(newState);

    final Duration remaining;
    final Duration elapsed;
    (remaining, elapsed) = newState.getRemainingAndElapsedTime(now);

    _eventController?.add(TimerStoppedEvent(
        timerState: newState, remainingTime: remaining, elapsedTime: elapsed));
  }

  void _handleTick() {
    if (state.value?.status != TimerStatus.running) {
      return;
    }

    DateTime now = DateTime.now();

    final currentState = state.value!;

    final Duration remainingTime;
    final Duration elapsedTime;
    (remainingTime, elapsedTime) = currentState.getRemainingAndElapsedTime(now);

    if (remainingTime <= Duration.zero) {
      _onTimerCompleted();
    } else {
      state = AsyncData(TimerState(
        timerType: currentState.timerType,
        status: currentState.status,
        timerDuration: currentState.timerDuration,
        startedAt: currentState.startedAt,
        pauses: currentState.pauses,
        pausedAt: currentState.pausedAt,
      ));
      _eventController?.add(TimerTickEvent(
          timerState: state.value!,
          remainingTime: remainingTime,
          elapsedTime: elapsedTime));
    }
  }

  void _onTimerCompleted() {
    final currentState = state.value!;
    _timer?.cancel();

    final newState = TimerState(
      timerType: currentState.timerType,
      status: TimerStatus.ended,
      timerDuration: currentState.timerDuration,
      startedAt: currentState.startedAt,
      pauses: currentState.pauses,
      pausedAt: null,
    );

    state = AsyncData(newState);
    _eventController?.add(TimerCompletedEvent(
        timerState: newState, elapsedTime: newState.timerDuration));
  }

  RunningTimerSession getCurrentSession() {
    final currentState = state.value!;
    if (currentState.status == TimerStatus.notStarted) {
      throw StateError('No active timer session');
    }

    return RunningTimerSession(
      sessionType: currentState.timerType,
      startedAt: currentState.startedAt!,
      pausedAt: currentState.pausedAt,
      pauses: currentState.pauses,
      totalDuration: currentState.timerDuration,
    );
  }

  TimerStatus getCurrentStatus() {
    return state.value?.status ?? TimerStatus.notStarted;
  }

  TimerType getCurrentTimerType() {
    return state.value?.timerType ?? TimerType.work;
  }

  Duration getRemainingTime() {
    return state.value?.getRemainingTime(DateTime.now()) ?? Duration.zero;
  }

  TimerState? getCurrentState() {
    return state.value;
  }
}

// timer_provider.dart
@riverpod
Stream<TimerEvent> timerEvents(Ref ref) {
  return ref.watch(pomodoroTimerProvider.notifier)._eventController!.stream;
}
