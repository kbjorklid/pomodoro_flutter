import 'package:pomodoro_app2/core/domain/timer_type.dart';

class TimerDurations {
  final Duration work;
  final Duration shortRest;
  final Duration longRest;
  TimerDurations({required this.work, required this.shortRest, required this.longRest});

  TimerDurations.initial()
      : work = const Duration(minutes: 25),
        shortRest = const Duration(minutes: 5),
        longRest = const Duration(minutes: 15);

  Duration getDuration(TimerType timerType) {
    switch (timerType) {
      case TimerType.work:
        return work;
      case TimerType.shortRest:
        return shortRest;
      case TimerType.longRest:
        return longRest;
    }
  }
}
