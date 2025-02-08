import 'package:flutter/material.dart';

/// Builder class for [DateTimeRange].
///
/// Allows to build a [DateTimeRange] by including [DateTime] objects,
/// and respects optional min/max boundaries.
class DateTimeRangeBuilder {
  DateTime? _start;
  DateTime? _end;
  final DateTime? _min;
  final DateTime? _max;

  /// Constructor with optional min and max [DateTime] boundaries.
  DateTimeRangeBuilder({DateTime? min, DateTime? max})
      : _min = min,
        _max = max {
    if (_min != null && _max != null && _min.isAfter(_max)) {
      throw ArgumentError(
          'Invalid boundaries: min date must be before max date.');
    }
  }

  /// Includes the given [time] in the [DateTimeRange] being built.
  void include(DateTime time) {
    DateTime start = _start ?? time;
    DateTime end = _end ?? time;

    if (time.isBefore(start)) {
      start = time;
    }
    if (time.isAfter(end)) {
      end = time;
    }

    if (_min != null && start.isBefore(_min)) {
      start = _min;
    }
    if (_max != null && end.isAfter(_max)) {
      end = _max;
    }
  }

  /// Returns the built [DateTimeRange].
  ///
  /// Returns the built [DateTimeRange].
  ///
  /// If no times have been included yet, returns a [DateTimeRange] with
  /// start and end set to the current time.
  DateTimeRange getDateTimeRange() {
    if (_start == null || _end == null) {
      throw StateError(
          'DateTimeRangeBuilder has not been initialized properly. Ensure include() method is called at least once.');
    }
    return DateTimeRange(start: _start!, end: _end!);
  }
}
