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

  void resume() {
    if (_pausedAt != null) {
      _pauses.add(PauseRecord(
        pausedAt: _pausedAt!,
        resumedAt: DateTime.now(),
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

  void _notifyStateListeners() {
    if (_stateListeners.isEmpty) return;
    final state = _state.toTimerState(DateTime.now());
    for (var listener in _stateListeners) {
      listener(state);
    }
  }

  void _notifySessionListeners(TimerSession session) {
    if (_sessionListeners.isEmpty) return;
    final now = DateTime.now();
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
      _completeSessionIfStarted();
      _state.updateTimerType(timerType, totalDuration);
      _notifyStateListeners();
    }
  }

  void startFromBeginning() {
    _completeSessionIfStarted();
    _state.startFromBeginning(DateTime.now());
    DomainEventBus.publish(TimerStartedEvent(timerType: _state._timerType));
    _startTimerTicks();
  }

  void resume() {
    if (_state.status != TimerStatus.paused) return;
    if (_state.getRemainingTime(DateTime.now()) <= Duration.zero) {
      _stopTimerIfEnded();
      return;
    } else {
      _state.resume();
      DomainEventBus.publish(TimerResumedEvent(timerType: _state._timerType));
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
    _notifyStateListeners();
  }

  void pause() {
    _timer?.cancel();
    _state.pause(DateTime.now());
    DomainEventBus.publish(TimerPausedEvent(timerType: _state._timerType));
    _notifyStateListeners();
  }

  bool _stopTimerIfEnded() {
    if (_isTimerEndReached()) {
      _timer?.cancel();
      _completeSessionIfStarted();
      _state.stop();
      _notifyStateListeners();
      _playTimerEndSoundUseCase.execute();
      return true;
    }
    return false;
  }

  bool _isTimerEndReached() {
    return _state.getRemainingTime(DateTime.now()) <= Duration.zero;
  }

  void _completeSessionIfStarted() {
    if (_state._startedAt != null) {
      final session = TimerSession(
        sessionType: _state._timerType,
        startedAt: _state._startedAt!,
        endedAt: DateTime.now(),
        pauses: _state._pauses,
        totalDuration: _state._totalDuration,
      );
      _notifySessionListeners(session);
      DomainEventBus.publish(TimerStoppedEvent(timerSession: session));
      _state.reset();
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _stateListeners.clear();
    _sessionListeners.clear();
  }
}
