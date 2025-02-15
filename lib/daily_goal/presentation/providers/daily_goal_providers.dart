import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_history_updates_provider.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_goal_providers.g.dart';

@riverpod
Future<int?> dailyPomodoroGoal(Ref ref) async {
  // Watch settings repository for changes
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getDailyPomodoroGoal();
}

@riverpod
Future<int> todaysPomodoroCount(Ref ref) async {
  final historyVersion = ref.watch(timerHistoryUpdatesProvider);


  final repository = ref.read(timerSessionRepositoryProvider);

  print('Fetching pomodoro count, history version: $historyVersion');

  return repository.getPomodoroCountForDate(DateTime.now());
}