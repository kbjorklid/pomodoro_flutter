import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer_history_updates_provider.g.dart';

@Riverpod(keepAlive: true)
class TimerHistoryUpdates extends _$TimerHistoryUpdates {
  @override
  int build() {
    return 0;
  }

  void notifyHistoryUpdated() {
    state++;
  }
}