import 'dart:async';

import 'domain_event.dart';

class DomainEventBus {
  static final _controller = StreamController<DomainEvent>.broadcast();

  static Stream<DomainEvent> get stream => _controller.stream;

  static void publish(DomainEvent event) {
    _controller.add(event);
  }

  static Stream<T> of<T extends DomainEvent>() {
    return stream.where((event) => event is T).cast<T>();
  }

  static void dispose() {
    _controller.close();
  }
}