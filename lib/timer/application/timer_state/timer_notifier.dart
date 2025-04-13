import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
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

class TimerOvertimeStartedEvent extends TimerRuntimeEvent {
  const TimerOvertimeStartedEvent(
      {required super.timerState,
      required super.remainingTime,
      required super.elapsedTime});
}

class TimerEndedEvent extends TimerRuntimeEvent {
  final DateTime endedAt;

  const TimerEndedEvent(
      {required super.timerState,
      required super.remainingTime,
      required super.elapsedTime,
      required this.endedAt});
}

class TimerCompletedEvent extends TimerEndedEvent {
  const TimerCompletedEvent(
      {required super.timerState,
      super.remainingTime = Duration.zero,
      required super.elapsedTime,
      required super.endedAt});
}

class TimerStoppedEvent extends TimerEndedEvent {
  const TimerStoppedEvent(
      {required super.timerState,
      required super.remainingTime,
      required super.elapsedTime,
      required super.endedAt});
}

class TimerResetEvent extends TimerEvent {
  const TimerResetEvent({required super.timerState});
}

final _logger = Logger();

@riverpod
class PomodoroTimer extends _$PomodoroTimer {
  Timer? _timer;
  StreamController<TimerEvent>? _eventController;
  late SettingsRepositoryPort _settingsRepository;
  late TimerDurations _durations;
  bool _overtimeStarted = false;

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
          await resetTimer();
        }
      });
    });

    return TimerState.initial(TimerType.work,
        _durations.getDuration(TimerType.work), await _isOvertimeActive());
  }

  Future<bool> _isOvertimeActive() async {
    if (state.value == null || state.value?.timerType != TimerType.work) {
      return false;
    }
    return await _settingsRepository.isAllowOvertimeEnabled();
  }

  Stream<TimerEvent> get events => _eventController!.stream;

  void startTimer([TimerType? timerType]) async {
    if (state.value?.status == TimerStatus.running) {
      return;
    }
    _logger.d("start timer for timer type: $timerType");
    _stopTicks();
    _overtimeStarted = false;
    timerType ??= getCurrentTimerType();

    final now = DateTime.now();
    final Duration duration = _durations.getDuration(timerType);

    final timerState = TimerState(
        timerType: timerType,
        status: TimerStatus.running,
        timerDuration: duration,
        startedAt: now,
        pauses: [],
        pausedAt: null,
        overtimeEnabled: await _isOvertimeActive());

    state = AsyncData(timerState);

    _eventController?.add(TimerStartedEvent(
        timerState: timerState,
        remainingTime: duration,
        elapsedTime: Duration.zero));
    _startTicks();
  }

  void _startTicks() {
    _logger.d("Starting ticks");
    _stopTicks(log: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _handleTick();
    });
  }

  void _stopTicks({bool log = true}) {
    if (log) {
      _logger.d("Stopping ticks");
    }
    _timer?.cancel();
  }

  void _handleTick() {
    if (state.value?.status != TimerStatus.running) {
      _logger.d("handleTick: timer is not running, so doing nothing.");
      return;
    }
    DateTime now = DateTime.now();
    final currentState = state.value!;
    _logger.d("handleTick: $currentState");

    final Duration remainingTime;
    final Duration elapsedTime;
    (remainingTime, elapsedTime) = currentState.getRemainingAndElapsedTime(now);

    if (remainingTime <= Duration.zero) {
      if (!currentState.overtimeEnabled) {
        _onTimerCompleted();
      } else if (!_overtimeStarted) {
        _onTimerOvertimeStart();
      }
    }
    if (currentState.overtimeEnabled || remainingTime > Duration.zero) {
      _sendTickEvent(currentState, remainingTime, elapsedTime);
    }
  }

  void _sendTickEvent(
      TimerState currentState, Duration remainingTime, Duration elapsedTime) {
    _logger.d(
        "Sending tick event; remaining: $remainingTime, elapsed: $elapsedTime");
    state = AsyncData(TimerStateBuilder(currentState).build());
    _eventController?.add(TimerTickEvent(
        timerState: state.value!,
        remainingTime: remainingTime,
        elapsedTime: elapsedTime));
  }

  Future<void> resetTimer([TimerType? timerType]) async {
    _stopTicks();
    timerType ??= getCurrentTimerType();
    _overtimeStarted = false;
    final duration = _durations.getDuration(timerType);
    state = AsyncData(TimerState(
      timerType: timerType,
      status: TimerStatus.notStarted,
      timerDuration: duration,
      startedAt: null,
      pauses: [],
      pausedAt: null,
      overtimeEnabled: await _isOvertimeActive(),
    ));
    _eventController?.add(TimerResetEvent(timerState: state.requireValue));
  }

  void pauseTimer() {
    if (state.value?.status != TimerStatus.running) {
      return;
    }
    _logger.d("Pausing timer");
    _stopTicks();

    final now = DateTime.now();

    var previousState = state.value!;
    final timerState = TimerStateBuilder(previousState)
        .withStatus(TimerStatus.paused)
        .withPausedAt(now)
        .build();

    state = AsyncData(timerState);

    _eventController?.add(TimerPausedEvent(
        timerState: timerState,
        remainingTime: timerState.getRemainingTime(now),
        elapsedTime: timerState.getElapsedTimeIgnoringPauses(now)));
  }

  void resumeTimer([DateTime? now]) {
    if (state.value?.status != TimerStatus.paused) {
      return;
    }
    _logger.d("Resuming timer");

    now ??= DateTime.now();

    final oldState = state.value!;

    final newState = TimerStateBuilder(oldState)
        .withAdditionalPause(PauseRecord(
          pausedAt: oldState.pausedAt!,
          resumedAt: now,
        ))
        .withStatus(TimerStatus.running)
        .withPausedAt(null)
        .build();

    state = AsyncData(newState);

    _eventController?.add(TimerResumedEvent(
        timerState: newState,
        remainingTime: newState.getRemainingTime(now),
        elapsedTime: newState.getElapsedTimeIgnoringPauses(now)));

    _startTicks();
  }

  void stopTimer() {
    if (state.value?.status == TimerStatus.notStarted) {
      return;
    }

    _stopTicks();

    final now = DateTime.now();
    final previousState = state.value!;

    final newStateBuilder = TimerStateBuilder(previousState)
        .withStatus(TimerStatus.ended)
        .withPausedAt(null);
    if (previousState.pausedAt != null) {
      var pauseRecord = PauseRecord(
        pausedAt: previousState.pausedAt!,
        resumedAt: now,
      );
      newStateBuilder.withAdditionalPause(pauseRecord);
    }
    var newState = newStateBuilder.build();
    state = AsyncData(newState);
    final Duration remaining;
    final Duration elapsed;
    (remaining, elapsed) = newState.getRemainingAndElapsedTime(now);

    DateTime stoppedAt = _getStopAtTime(previousState, now);
    _eventController?.add(TimerStoppedEvent(
        timerState: newState,
        remainingTime: remaining,
        elapsedTime: elapsed,
        endedAt: stoppedAt));
  }

  DateTime _getStopAtTime(TimerState? timerState, [DateTime? now]) {
    now ??= DateTime.now();
    if (timerState == null) {
      return now;
    }
    final DateTime? estimatedEndTime = timerState.estimatedEndTime;
    if (estimatedEndTime != null && estimatedEndTime.isBefore(now)) {
      return estimatedEndTime;
    }
    return now;
  }

  void _onTimerOvertimeStart() {
    _overtimeStarted = true;
    DateTime now = DateTime.now();
    final currentState = state.value!;

    final Duration remainingTime;
    final Duration elapsedTime;
    (remainingTime, elapsedTime) = currentState.getRemainingAndElapsedTime(now);

    _eventController?.add(TimerOvertimeStartedEvent(
      timerState: currentState,
      remainingTime: remainingTime,
      elapsedTime: elapsedTime,
    ));
  }

  void _onTimerCompleted() {
    final previousState = state.value!;
    _stopTicks();

    final newState = TimerStateBuilder(previousState)
        .withStatus(TimerStatus.ended)
        .withPausedAt(null)
        .build();

    state = AsyncData(newState);
    _eventController?.add(TimerCompletedEvent(
        timerState: newState,
        elapsedTime: newState.timerDuration,
        endedAt: _getStopAtTime(previousState)));
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

  bool changeTimerTypeOnTheFly(TimerType newType) {
    final currentState = state.value!;
    final currentType = currentState.timerType;

    if (newType == currentType) {
      return false;
    }

    final Duration newDuration = _durations.getDuration(newType);
    if (newDuration <=
        currentState.getElapsedTimeIgnoringPauses(DateTime.now())) {
      return false;
    }

    final TimerState newState = TimerStateBuilder(currentState)
        .withTimerType(newType)
        .withTimerDuration(newDuration)
        .build();
    state = AsyncData(newState);
    return true;
  }
}

@riverpod
Stream<TimerEvent> timerEvents(Ref ref) {
  return ref.watch(pomodoroTimerProvider.notifier)._eventController!.stream;
}
