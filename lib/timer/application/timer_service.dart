import 'dart:async';
import 'package:pomodoro_app2/settings/infrastructure/settings_repository.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timer_type.dart';

class _TimerRuntimeState {
  TimerType _timerType = TimerType.work;
  Duration _totalDuration = Duration(minutes:25);
  TimerStatus _status = TimerStatus.notStarted;
  DateTime? _startedAt;
  Duration _spentInPause = Duration.zero;
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
    _spentInPause = Duration.zero;
  }

  void pause(DateTime now) {
    _status = TimerStatus.paused;
    _pausedAt ??= now;
  }

  void resume() {
    _updateTimeSpentInPause();
    _status = TimerStatus.running;
  }

  void stop() {
    _updateTimeSpentInPause();
    _status = TimerStatus.ended;
    _pausedAt = null;
  }

  void reset() {
    _status = TimerStatus.notStarted;
    _startedAt = null;
    _spentInPause = Duration.zero;
    _pausedAt = null;
  }

  void _updateTimeSpentInPause() {
    if (_pausedAt == null) return;
    _spentInPause += DateTime.now().difference(_pausedAt!);
  }

  Duration getRemainingTime(DateTime now) {
    if (_status == TimerStatus.notStarted) return _totalDuration;
    if (_status == TimerStatus.ended) return Duration.zero;

    assert ((status == TimerStatus.paused) == (_pausedAt != null));
    DateTime comparisonTarget = _pausedAt ?? now;
    final timePassed = comparisonTarget.difference(_startedAt!) - _spentInPause;
    if (timePassed >= _totalDuration) return Duration.zero;
    return _totalDuration - timePassed;
  }

  TimerState toTimerState(DateTime now) {
    return TimerState(
      timerType: _timerType,
      totalTime: _totalDuration,
      remainingTime: getRemainingTime(now),
      status: _status
    );
  }
}

typedef TimerStateListener = void Function(TimerState);

/// A service class that manages the timer logic,
/// independently of the UI.
class TimerService  {
  final SettingsRepository _settings;
  Timer? _timer;
  final _TimerRuntimeState _state = _TimerRuntimeState();

  final List<TimerStateListener> listeners = [];

  TimerState get state => _state.toTimerState(DateTime.now());

  TimerService(this._settings) {
    setTimerType(TimerType.work);
  }

  void addListener(TimerStateListener listener) {
    if (!listeners.contains(listener)) {
      listeners.add(listener);
    }
  }
  
  void removeListener(TimerStateListener listener) {
    listeners.remove(listener);
  }
  
  void _notifyListeners() {
    if (listeners.isEmpty) return;
    final state = _state.toTimerState(DateTime.now());
    for (var listener in listeners) {
      listener(state);
    }
  }

  void setTimerType(TimerType timerType) async {
    Duration totalDuration = await (timerType == TimerType.work
        ? _settings.getWorkDuration()
        : _settings.getRestDuration());
    assert (totalDuration.inSeconds > 0);
    if (_state._timerType != timerType || _state._totalDuration != totalDuration) {
      _state.updateTimerType(timerType, totalDuration);
      _notifyListeners();
    }
  }

  void startTimerOrPause() {
    if (_state.status == TimerStatus.running) {
      pause();
    } else {
      startOrContinue();
    }
  }

  void startOrContinue() {
    if (_state.status == TimerStatus.running) return;
    if (_state.status == TimerStatus.paused) {
      _resume();
    } else {
      _startFromBeginning();
    }
  }

  void _startFromBeginning() {
    _state.startFromBeginning(DateTime.now());
    _startTimerTicks();
  }
  
  void _resume() {
    if (_state.status == TimerStatus.paused) {
      if (_state.getRemainingTime(DateTime.now()) <= Duration.zero) {
        _handleTimerEnd();
        return;
      } else {
        _state.resume();
        _startTimerTicks();
      }
    }
  }
  
  void _startTimerTicks() {
    _tick();
    _timer ??= Timer.periodic(Duration(seconds: 1), (_) {
        _tick();
      });
  }

  void _tick() {
    if (_stopTimerIfEnded()) return;
    _notifyListeners();
  }

  void _handleTimerEnd() {
    _timer?.cancel();
    _notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _state.pause(DateTime.now());
    _notifyListeners();
  }

  bool _stopTimerIfEnded() {
    if (_state.status != TimerStatus.running) return false;
    if (_isTimerEndReached()) {
      _timer?.cancel();
      _state.stop();
      _notifyListeners();
      return true;
    }
    return false;
  }

  bool _isTimerEndReached() {
    return _state.getRemainingTime(DateTime.now()) <= Duration.zero;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    listeners.clear();
  }
}
