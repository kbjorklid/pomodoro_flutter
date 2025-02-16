import 'package:pomodoro_app2/core/domain/common_key_value_store_port.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesKeyValueStore implements CommonKeyValueStore {
  static SharedPreferencesKeyValueStore? _instance;

  static SharedPreferencesKeyValueStore get instance =>
      _instance ??= SharedPreferencesKeyValueStore._internal();

  final String prefix = 'kvstore.';

  SharedPreferencesKeyValueStore._internal();

  String _prefixedKey(String key) => '${prefix}_$key';

  @override
  Future<void> save<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    final prefixedKey = _prefixedKey(key);

    if (value is String) {
      await prefs.setString(prefixedKey, value);
    } else if (value is int) {
      await prefs.setInt(prefixedKey, value);
    } else if (value is bool) {
      await prefs.setBool(prefixedKey, value);
    } else if (value is double) {
      await prefs.setDouble(prefixedKey, value);
    } else if (value is List<String>) {
      await prefs.setStringList(prefixedKey, value);
    } else if (value is DateTime) {
      await prefs.setInt(prefixedKey, value.millisecondsSinceEpoch);
    } else {
      throw ArgumentError('Unsupported type: ${value.runtimeType}');
    }
  }

  @override
  Future<T?> get<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final prefixedKey = _prefixedKey(key);

    if (T == String) {
      return prefs.getString(prefixedKey) as T?;
    } else if (T == int) {
      return prefs.getInt(prefixedKey) as T?;
    } else if (T == bool) {
      return prefs.getBool(prefixedKey) as T?;
    } else if (T == double) {
      return prefs.getDouble(prefixedKey) as T?;
    } else if (T == (List<String>)) {
      return prefs.getStringList(prefixedKey) as T?;
    } else if (T == DateTime) {
      final milliseconds = prefs.getInt(prefixedKey);
      return milliseconds != null
          ? DateTime.fromMillisecondsSinceEpoch(milliseconds) as T
          : null;
    }

    return null;
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final prefixedKey = _prefixedKey(key);
    await prefs.remove(prefixedKey);
  }
}
