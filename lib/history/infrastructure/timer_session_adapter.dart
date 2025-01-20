import 'package:hive/hive.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

part 'timer_session_adapter.g.dart';

@HiveType(typeId: 1)
class TimerSessionAdapter extends HiveObject {
  @HiveField(0)
  final TimerSession session;

  TimerSessionAdapter(this.session);
}
