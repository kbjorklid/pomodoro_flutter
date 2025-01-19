enum NotificationSound {
  chicken,
  ding,
  gentle,
  jingle
  ;

  @override
  String toString() {
    return name[0].toUpperCase() + name.substring(1).replaceAll('_', ' ');
  }

  static NotificationSound fromName(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => NotificationSound.ding,
    );
  }
}
