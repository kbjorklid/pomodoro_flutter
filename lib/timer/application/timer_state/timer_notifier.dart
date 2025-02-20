// timer_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/settings/domain/timer_durations.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_notifier.g.dart';
sealed class TimerEvent {
  const TimerEvent();
}

class TimerTickEvent extends TimerEvent {
  final Duration remainingTime;
  const TimerTickEvent(this.remainingTime);
}

class TimerStartedEvent extends TimerEvent {
  final TimerType timerType;
  final Duration duration;
  const TimerStartedEvent(this.timerType, this.duration);
}

class TimerPausedEvent extends TimerEvent {
  const TimerPausedEvent();
}

class TimerResumedEvent extends TimerEvent {
  const TimerResumedEvent();
}

class TimerCompletedEvent extends TimerEvent {
  const TimerCompletedEvent();
}

class TimerStoppedEvent extends TimerEvent {
  const TimerStoppedEvent();
}

@riverpod
class PomodoroTimer extends _$PomodoroTimer {
  Timer? _timer;
  StreamController<TimerEvent>? _eventController;
  TimerDurations _durations = TimerDurations.initial();

  @override
  FutureOr<TimerState> build() {
    _eventController = StreamController<TimerEvent>.broadcast();
    ref.onDispose(() {
      _timer?.cancel();
      _eventController?.close();
    });
    return TimerState.initial();
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
    state = AsyncData(TimerState(
      timerType: timerType,
      status: TimerStatus.running,
      timerDuration: duration,
      remainingTime: duration,
      startedAt: now,
      pauses: [],
      pausedAt: null,
    ));

    _eventController?.add(TimerStartedEvent(timerType, duration));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _handleTick();
    });
  }

  void resetTimer([TimerType? timerType]) {
    timerType ??= getCurrentTimerType();
    if (state.value?.status == TimerStatus.notStarted &&
        timerType == getCurrentTimerType()) {
      return;
    }

    _timer?.cancel();

    final TimerState? oldState = state.value;
    if (oldState != null) {
      final duration = _durations.getDuration(timerType);
      state = AsyncData(TimerState(
        timerType: timerType,
        status: TimerStatus.notStarted,
        timerDuration: duration,
        remainingTime: duration,
        startedAt: null,
        pauses: [],
        pausedAt: null,
      ));
    }
  }

  void pauseTimer() {
    if (state.value?.status != TimerStatus.running) {
      return;
    }

    _timer?.cancel();
    final now = DateTime.now();

    state = AsyncData(TimerState(
      timerType: state.value!.timerType,
      status: TimerStatus.paused,
      timerDuration: state.value!.timerDuration,
      remainingTime: state.value!.remainingTime,
      startedAt: state.value!.startedAt,
      pauses: [...state.value!.pauses],
      pausedAt: now,
    ));

    _eventController?.add(const TimerPausedEvent());
  }

  void resumeTimer() {
    if (state.value?.status != TimerStatus.paused) {
      return;
    }

    final now = DateTime.now();

    state = AsyncData(TimerState(
      timerType: state.value!.timerType,
      status: TimerStatus.running,
      timerDuration: state.value!.timerDuration,
      remainingTime: state.value!.remainingTime,
      startedAt: state.value!.startedAt,
      pauses: [
        ...state.value!.pauses,
        PauseRecord(
          pausedAt: state.value!.pausedAt!,
          resumedAt: now,
        ),
      ],
      pausedAt: null,
    ));

    _eventController?.add(const TimerResumedEvent());

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

    state = AsyncData(TimerState(
      timerType: currentState.timerType,
      status: TimerStatus.ended,
      timerDuration: currentState.timerDuration,
      remainingTime: currentState.remainingTime,
      startedAt: currentState.startedAt,
      pauses: finalPauses,
      pausedAt: null,
    ));

    _eventController?.add(const TimerStoppedEvent());
  }

  void _handleTick() {
    if (state.value?.status != TimerStatus.running) {
      return;
    }

    final currentState = state.value!;
    final newRemainingTime = currentState.remainingTime - const Duration(seconds: 1);

    if (newRemainingTime <= Duration.zero) {
      _timer?.cancel();
      state = AsyncData(TimerState(
        timerType: currentState.timerType,
        status: TimerStatus.ended,
        timerDuration: currentState.timerDuration,
        remainingTime: Duration.zero,
        startedAt: currentState.startedAt,
        pauses: currentState.pauses,
        pausedAt: null,
      ));
      _eventController?.add(const TimerCompletedEvent());
    } else {
      state = AsyncData(TimerState(
        timerType: currentState.timerType,
        status: currentState.status,
        timerDuration: currentState.timerDuration,
        remainingTime: newRemainingTime,
        startedAt: currentState.startedAt,
        pauses: currentState.pauses,
        pausedAt: currentState.pausedAt,
      ));
      _eventController?.add(TimerTickEvent(newRemainingTime));
    }
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
    return state.value?.remainingTime ?? Duration.zero;
  }

  TimerState? getCurrentState() {
    return state.value;
  }
}

// timer_provider.dart
@riverpod
Stream<TimerEvent> timerEvents(Ref ref) {
  return ref.watch(pomodoroTimerProvider.notifier).events;
}