import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/sound/domain/sound_player_port.dart';
import 'package:pomodoro_app2/sound/presentation/providers/sound_player_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'play_timer_end_sound_use_case.g.dart';

class PlayTimerEndSoundUseCase {
  final SoundPlayerPort _soundPlayer;
  final SettingsRepositoryPort _settingsRepository;

  PlayTimerEndSoundUseCase(this._soundPlayer, this._settingsRepository);

  Future<void> execute() async {
    final sound = await _settingsRepository.getTimerEndSound();
    await _soundPlayer.playSound(sound);
  }
}

@riverpod
PlayTimerEndSoundUseCase playTimerEndSoundUseCase(Ref ref) {
  return PlayTimerEndSoundUseCase(
    ref.watch(soundPlayerProvider),
    ref.watch(settingsRepositoryProvider),
  );
}