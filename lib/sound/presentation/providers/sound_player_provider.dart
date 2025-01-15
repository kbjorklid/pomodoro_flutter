import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/sound/infrastructure/sound_player_adapter.dart';
import 'package:pomodoro_app2/sound/domain/sound_player_port.dart';

final soundPlayerProvider = Provider<SoundPlayerPort>((ref) {
  return SoundPlayerAdapter();
});
