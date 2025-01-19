import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/history/infrastructure/timer_session_repository.dart';

final timerSessionRepositoryProvider = Provider<TimerSessionRepository>(
  (ref) => TimerSessionRepository(),
);
