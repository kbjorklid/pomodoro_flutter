import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/common_key_value_store_port.dart';
import 'package:pomodoro_app2/core/infrastructure/shared_preferences_key_value_store.dart';

// Use an int to track the number of daily resets.
final dailyResetProvider = StateProvider<int>((ref) => 0);

final keyValueStoreProvider = Provider<CommonKeyValueStore>((ref) {
  return SharedPreferencesKeyValueStore.instance;
});
