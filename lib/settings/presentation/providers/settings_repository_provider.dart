import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/domain/settings_repository_port.dart';
import 'package:pomodoro_app2/settings/infrastructure/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepositoryPort>((ref) {
  return SettingsRepository();
});
