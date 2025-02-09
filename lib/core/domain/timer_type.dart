/// Represents the type of timer session
enum TimerType {
  /// Work session
  work,
  
  /// Short rest session
  shortRest,
  
  /// Long rest session
  longRest;

  bool get isRest => this != work;

  bool get isWork => this == work;
}

