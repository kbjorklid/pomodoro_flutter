import 'dart:async';

import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_running_events.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/settings/infrastructure/settings_repository.dart';
import 'package:pomodoro_app2/timer/application/play_timer_end_sound_use_case.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

class _TimerRuntimeState {
  TimerType _timerType = TimerType.work;
  Duration _totalDuration = Duration(minutes: 25);
  TimerStatus _status = TimerStatus.notStarted;
  DateTime? _startedAt;
  List<PauseRecord> _pauses = [];
  DateTime? _pausedAt;

  TimerStatus get status => _status;

  _TimerRuntimeState() {
    reset();
  }

  void updateTimerType(TimerType newType, Duration totalDuration) {
    reset();
    _timerType = newType;
    _totalDuration = totalDuration;
  }

  void startFromBeginning(DateTime now) {
    _status = TimerStatus.running;
    _startedAt = now;
    _pausedAt = null;
    _pauses = [];
  }

  void pause(DateTime now) {
    _status = TimerStatus.paused;
    _pausedAt ??= now;
  }

  void resume([DateTime? now]) {
    now ??= DateTime.now();
    if (_pausedAt != null) {
      _pauses.add(PauseRecord(
        pausedAt: _pausedAt!,
        resumedAt: now,
      ));
      _pausedAt = null;
    }
    _status = TimerStatus.running;
  }

  void stop() {
    _status = TimerStatus.ended;
    _pausedAt = null;
  }

  void reset() {
    _status = TimerStatus.notStarted;
    _startedAt = null;
    _pauses.clear();
    _pausedAt = null;
  }


  Duration getRemainingTime(DateTime now) {
    if (_status == TimerStatus.notStarted) return _totalDuration;
    if (_status == TimerStatus.ended) return Duration.zero;

    assert((status == TimerStatus.paused) == (_pausedAt != null));
    DateTime comparisonTarget = _pausedAt ?? now;
    final totalPauseDuration =
        _pauses.fold(Duration.zero, (sum, pause) => sum + pause.duration);
    final timePassed =
        comparisonTarget.difference(_startedAt!) - totalPauseDuration;
    if (timePassed >= _totalDuration) return Duration.zero;
    return _totalDuration - timePassed;
  }

  TimerState toTimerState(DateTime now) {
    return TimerState(
        timerType: _timerType,
        status: _status,
        timerDuration: _totalDuration,
        remainingTime: getRemainingTime(now),
        startedAt: _startedAt,
        pauses: _pauses,
        pausedAt: _pausedAt);
  }
}

typedef TimerStateListener = void Function(TimerState);
typedef TimerSessionListener = void Function(TimerSession);

/// A service class that manages the timer logic,
/// independently of the UI.
class TimerService {
  final SettingsRepository _settings;
  final PlayTimerEndSoundUseCase _playTimerEndSoundUseCase;
  Timer? _timer;
  final _TimerRuntimeState _state = _TimerRuntimeState();

  final List<TimerStateListener> _stateListeners = [];
  final List<TimerSessionListener> _sessionListeners = [];
  DateTime? _lastTimeSecondsChanged;
  DateTime? _lastTimeMinutesChanged;

  TimerState get state => _state.toTimerState(DateTime.now());

  TimerService(this._settings, this._playTimerEndSoundUseCase) {
    setTimerType(TimerType.work);
  }

  void addStateListener(TimerStateListener listener) {
    if (!_stateListeners.contains(listener)) {
      _stateListeners.add(listener);
    }
  }

  void removeStateListener(TimerStateListener listener) {
    _stateListeners.remove(listener);
  }

  void addSessionListener(TimerSessionListener listener) {
    if (!_sessionListeners.contains(listener)) {
      _sessionListeners.add(listener);
    }
  }

  void removeSessionListener(TimerSessionListener listener) {
    _sessionListeners.remove(listener);
  }

  void _notifyStateListeners([DateTime? now]) {
    now ??= DateTime.now();
    if (_stateListeners.isEmpty) return;
    final state = _state.toTimerState(now);
    for (var listener in _stateListeners) {
      listener(state);
    }
  }

  TimerState getState() {
    final state = _state.toTimerState(DateTime.now());
    return state;
  }

  void _notifySessionListeners(TimerSession session) {
    if (_sessionListeners.isEmpty) return;
    for (var listener in _sessionListeners) {
      listener(session);
    }
  }

  void setTimerType(TimerType timerType) async {
    Duration totalDuration = await (timerType == TimerType.work
        ? _settings.getWorkDuration()
        : _settings.getRestDuration());
    assert(totalDuration.inSeconds > 0);
    if (_state._timerType != timerType ||
        _state._totalDuration != totalDuration) {
      DateTime now = DateTime.now();
      _completeSessionIfStarted(now);
      _state.updateTimerType(timerType, totalDuration);
      _notifyStateListeners(now);
    }
  }

  void startFromBeginning([DateTime? now]) {
    now ??= DateTime.now();
    _completeSessionIfStarted(now);
    _state.startFromBeginning(now);
    DomainEventBus.publish(
        TimerStartedEvent(timerState: _state.toTimerState(now)));
    _startTimerTicks();
  }

  void resume([DateTime? now]) {
    now ??= DateTime.now();
    if (_state.status != TimerStatus.paused) return;
    if (_state.getRemainingTime(now) <= Duration.zero) {
      _stopTimerIfEnded(now);
      return;
    } else {
      _state.resume(now);
      DomainEventBus.publish(
          TimerResumedEvent(timerState: _state.toTimerState(now)));
      _startTimerTicks();
    }
  }

  void _startTimerTicks() {
    if (_timer != null && _timer!.isActive) return;
    _tick();
    _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      _tick();
    });
  }

  void _tick() {
    if (_stopTimerIfEnded()) return;
    final DateTime now = DateTime.now();
    TimerState? stateToNotify;
    if (_lastTimeSecondsChanged == null ||
        _lastTimeSecondsChanged!.second != now.second) {
      stateToNotify = _state.toTimerState(now);
      DomainEventBus.publish(
          TimerSecondsChangedEvent(timerState: stateToNotify));
      _lastTimeSecondsChanged = now;
    }
    if (_lastTimeMinutesChanged == null ||
        _lastTimeMinutesChanged!.minute != now.minute) {
      stateToNotify ??= _state.toTimerState(now);
      DomainEventBus.publish(
          TimerMinutesChangedEvent(timerState: stateToNotify));
      _lastTimeMinutesChanged = now;
    }
    _notifyStateListeners(now);
  }

  void pause() {
    var now = DateTime.now();
    _timer?.cancel();
    _state.pause(now);
    DomainEventBus.publish(
        TimerPausedEvent(timerState: _state.toTimerState(now)));
    _notifyStateListeners(now);
  }

  bool _stopTimerIfEnded([DateTime? now]) {
    now ??= DateTime.now();
    if (_isTimerEndReached(now)) {
      _timer?.cancel();
      _completeSessionIfStarted(now);
      _state.stop();
      _notifyStateListeners(now);
      _playTimerEndSoundUseCase.execute();
      return true;
    }
    return false;
  }

  bool _isTimerEndReached([DateTime? now]) {
    now ??= DateTime.now();
    return _state.getRemainingTime(now) <= Duration.zero;
  }

  void _completeSessionIfStarted([DateTime? now]) {
    TimerSession? session = finalizeSessionIfStarted(now);
    if (session != null) {
      _notifySessionListeners(session);
      DomainEventBus.publish(TimerStoppedEvent(timerSession: session));
      _state.reset();
    }
  }

  TimerSession? finalizeSessionIfStarted([DateTime? now]) {
    now ??= DateTime.now();
    if (_state._startedAt != null) {
      _timer?.cancel();
      final session = TimerSession(
        sessionType: _state._timerType,
        startedAt: _state._startedAt!,
        endedAt: now,
        pauses: _state._pauses,
        totalDuration: _state._totalDuration,
      );
      _state.reset();
      return session;
    }
    return null;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _stateListeners.clear();
    _sessionListeners.clear();
  }
}
