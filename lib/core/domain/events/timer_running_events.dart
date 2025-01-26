
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

import 'domain_event.dart';

abstract class TimerEvent extends DomainEvent {
  TimerType timerType;
  TimerEvent({required this.timerType});

  @override
  toString() => '$runtimeType { timerType: $timerType }';
}

abstract class TimerRuntimeEvent extends TimerEvent {
  final TimerState timerState;

  TimerRuntimeEvent({required this.timerState})
      : super(timerType: timerState.timerType);
}

class TimerStartedEvent extends TimerEvent {
  TimerStartedEvent({required super.timerType});
}

class TimerPausedEvent extends TimerEvent {
  TimerPausedEvent({required super.timerType});
}

class TimerResumedEvent extends TimerEvent {
  TimerResumedEvent({required super.timerType});
}

class TimerStoppedEvent extends TimerEvent {
  TimerSession timerSession;
  TimerStoppedEvent({required this.timerSession})
      : super(timerType: timerSession.sessionType);
}

class TimerSecondsChangedEvent extends TimerRuntimeEvent {
  TimerSecondsChangedEvent({required super.timerState});
}

class TimerMinutesChangedEvent extends TimerRuntimeEvent {
  TimerMinutesChangedEvent({required super.timerState});
}