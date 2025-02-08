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

  DateTimeRangeBuilder.forDay(DateTime day)
      : _min = DateTime(day.year, day.month, day.day),
        _max = DateTime(day.year, day.month, day.day).add(Duration(days: 1));

  /// Includes the given [time] in the [DateTimeRange] being built.
  void include(DateTime time) {
    if (!_isAtMinBoundary()) {
      DateTime start = _earlier(_start, time);
      _start = _later(_min, start);
    }
    if (!_isAtMaxBoundary()) {
      DateTime end = _later(_end, time);
      _end = _earlier(_max, end);
    }
  }

  void ensureMinDurationExpandingToPast(
      {required Duration amount, bool expandToFutureIfNecessary = true}) {
    if (_isAtMinBoundary() && _isAtMaxBoundary()) return;
    if (amount.isNegative) {
      throw ArgumentError('Amount must be positive.');
    }
    if (_start == null) {
      throw StateError('Cannot expand to past when no start date is set.');
    }
    if (_duration() < amount) {
      include(_end!.add(-amount));
      if (expandToFutureIfNecessary) {
        include(_start!.add(amount));
      }
    }
  }

  bool _isAtMinBoundary() {
    return _start == _min;
  }

  bool _isAtMaxBoundary() {
    return _end == _max;
  }

  Duration _duration() {
    if (_start == null || _end == null) {
      throw StateError(
          'Cannot calculate duration when start or end date is null.');
    }
    return _end!.difference(_start!);
  }

  static DateTime _earlier(DateTime? a, DateTime? b) {
    if (a == null && b == null) throw ArgumentError('Both dates are null.');
    if (a == null) return b!;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }

  static DateTime _later(DateTime? a, DateTime? b) {
    if (a == null && b == null) throw ArgumentError('Both dates are null.');
    if (a == null) return b!;
    if (b == null) return a;
    return a.isBefore(b) ? b : a;
  }

  void includeRange(DateTimeRange range) {
    if (!_isAtMinBoundary()) include(range.start);
    if (!_isAtMaxBoundary()) include(range.end);
  }

  /// Returns the built [DateTimeRange].
  ///
  /// Returns the built [DateTimeRange].
  ///
  /// If no times have been included yet, returns a [DateTimeRange] with
  /// start and end set to the current time.
  DateTimeRange getDateTimeRange() {
    if (_start == null || _end == null) {
      throw StateError('DateTimeRangeBuilder has not been initialized properly.'
          ' Ensure include() method is called at least once.');
    }
    return DateTimeRange(start: _start!, end: _end!);
  }
}
