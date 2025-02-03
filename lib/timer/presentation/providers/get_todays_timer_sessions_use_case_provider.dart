import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/get_todays_timer_sessions_use_case.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

final todaysTimerSessionsUseCaseProvider =
    Provider<GetTodaysTimerSessionsUseCase>((ref) {
  final useCase = GetTodaysTimerSessionsUseCase(
    ref.read(timerProvider),
    ref.read(timerSessionRepositoryProvider),
  );

  // This will automatically call dispose when the provider is disposed
  ref.onDispose(() {
    useCase.dispose();
  });

  return useCase;
});
