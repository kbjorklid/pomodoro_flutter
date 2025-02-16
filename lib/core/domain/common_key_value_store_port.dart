abstract class CommonKeyValueStore {
  /// Saves a value to the store.
  ///
  /// The value can be of any type.
  Future<void> save<T>(String key, T value);

  /// Retrieves a value from the store.
  ///
  /// Returns null if the key does not exist.
  Future<T?> get<T>(String key);

  /// Deletes a value from the store.
  Future<void> delete(String key);
}
