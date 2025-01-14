import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/infrastructure/sound_player_adapter.dart';
import 'package:pomodoro_app2/timer/domain/sound_player_port.dart';

final soundPlayerProvider = Provider<SoundPlayerPort>((ref) {
  return SoundPlayerAdapter();
});
