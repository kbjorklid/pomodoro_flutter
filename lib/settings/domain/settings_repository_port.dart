import 'package:flutter/foundation.dart';

abstract class SettingsRepositoryPort {
  Future<Duration> getWorkDuration();
  Future<void> setWorkDuration(Duration duration);
  
  Future<Duration> getRestDuration();
  Future<void> setRestDuration(Duration duration);
}
