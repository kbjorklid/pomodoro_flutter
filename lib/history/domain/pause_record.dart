import 'package:freezed_annotation/freezed_annotation.dart';

part 'pause_record.freezed.dart';

/// Represents a single pause during a timer session
@freezed
class PauseRecord with _$PauseRecord {
  const PauseRecord._();
  
  const factory PauseRecord({
    /// When the timer was paused
    required DateTime pausedAt,
    
    /// When the timer was resumed
    required DateTime resumedAt,
  }) = _PauseRecord;

  /// Duration of the pause (derived value)
  Duration get duration => resumedAt.difference(pausedAt);
}
