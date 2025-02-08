import 'package:flutter/material.dart';

/// Utility class for formatting time durations into human-readable strings.
class TimeFormatter {
  /// Formats a [Duration] into "h:mm" format (e.g., "3:42").
  static String toHoursAndMinutes(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  /// Formats a [Duration] into a human-readable string.
  ///
  /// If the duration is less than 60 minutes, it outputs "m minutes" (e.g., "58 minutes").
  /// Otherwise, it uses [toHoursAndMinutes] to format the duration (e.g., "7:52").
  static String toHumanReadable(Duration duration) {
    if (duration < const Duration(minutes: 60)) {
      final minutes = duration.inMinutes;
      return '$minutes minutes';
    } else {
      return toHoursAndMinutes(duration);
    }
  }
}
