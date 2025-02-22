import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/sound/presentation/providers/sound_player_provider.dart';
import 'package:pomodoro_app2/timer/application/timer_state/timer_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_end_sound_provider.g.dart';

/// Provider that listens to timer events and saves completed sessions to the repository
@Riverpod(keepAlive: true)
void sessionEndSoundNotifier(Ref ref) {
  final sound = ref.read(soundPlayerProvider);
  final settings = ref.read(settingsRepositoryProvider);

  ref.listen(timerEventsProvider, (previous, next) async {
    // Handle the AsyncValue wrapper
    next.whenData((event) async {
      if (event is TimerCompletedEvent) {
        final timerEndSound = await settings.getTimerEndSound();
        await sound.playSound(timerEndSound);
      }
    });
  });
}