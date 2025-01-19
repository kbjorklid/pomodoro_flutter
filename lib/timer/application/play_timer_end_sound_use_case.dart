import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/sound/domain/sound_player_port.dart';

class PlayTimerEndSoundUseCase {
  final SoundPlayerPort _soundPlayer;
  final SettingsRepositoryPort _settingsRepository;

  PlayTimerEndSoundUseCase(this._soundPlayer, this._settingsRepository);

  Future<void> execute() async {
    final sound = await _settingsRepository.getTimerEndSound();
    await _soundPlayer.playSound(sound);
  }
}
