enum Sound {
  chicken,
  ding,
  gentle,
  jingle
  ;

  @override
  String toString() {
    return name[0].toUpperCase() + name.substring(1).replaceAll('_', ' ');
  }
}
