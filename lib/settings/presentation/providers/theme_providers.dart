import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/domain/app_theme_mode.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

/// Notifier responsible for managing the application's theme mode.
///
/// It loads the initial theme mode from the settings repository and
/// provides a method to update the theme mode preference.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  FutureOr<AppThemeMode> build() async {
    // Load the initial theme mode from the repository
    final repository = ref.watch(settingsRepositoryProvider);
    return await repository.getThemeMode();
  }

  /// Updates the application's theme mode preference.
  Future<void> updateThemeMode(AppThemeMode newMode) async {
    final repository = ref.read(settingsRepositoryProvider);
    // Set the new state optimistically
    state = AsyncData(newMode);
    // Persist the change
    await repository.setThemeMode(newMode);
  }
}
