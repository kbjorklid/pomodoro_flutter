import 'dart:async';

import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/settings/infrastructure/settings_repository.dart';
import 'package:pomodoro_app2/timer/application/play_timer_end_sound_use_case.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';

class _TimerRuntimeState {
  TimerType _timerType = TimerType.work;
  Duration _totalDuration = Duration(minutes: 25);
  TimerStatus _status = TimerStatus.notStarted;
  DateTime? _startedAt;
  final List<PauseRecord> _pauses = [];
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
    _pauses.clear();
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
        totalTime: _totalDuration,
        remainingTime: getRemainingTime(now),
        status: _status);
  }
}

typedef TimerStateListener = void Function(TimerState);

/// A service class that manages the timer logic,
/// independently of the UI.
class TimerService {
  final SettingsRepository _settings;
  final PlayTimerEndSoundUseCase _playTimerEndSoundUseCase;
  Timer? _timer;
  final _TimerRuntimeState _state = _TimerRuntimeState();

  final List<TimerStateListener> listeners = [];

  TimerState get state => _state.toTimerState(DateTime.now());

  TimerService(this._settings, this._playTimerEndSoundUseCase) {
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
    assert(totalDuration.inSeconds > 0);
    if (_state._timerType != timerType ||
        _state._totalDuration != totalDuration) {
      _state.updateTimerType(timerType, totalDuration);
      _notifyListeners();
    }
  }

  void startFromBeginning() {
    _state.startFromBeginning(DateTime.now());
    _startTimerTicks();
  }

  void resume() {
    if (_state.status != TimerStatus.paused) return;
    if (_state.getRemainingTime(DateTime.now()) <= Duration.zero) {
      _handleTimerEnd();
      return;
    } else {
      _state.resume();
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
      _playTimerEndSoundUseCase.execute();
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
