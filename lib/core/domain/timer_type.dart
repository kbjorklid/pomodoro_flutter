import 'package:hive/hive.dart';

part 'timer_type.g.dart';

/// Represents the type of timer session
@HiveType(typeId: 3)
enum TimerType {
  /// Work session
  @HiveField(0)
  work,
  
  /// Rest session
  @HiveField(1)
  rest,
  
  /// Any type of session
  @HiveField(2)
  any,
}

