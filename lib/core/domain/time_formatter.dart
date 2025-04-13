/// Utility class for formatting time durations into human-readable strings.
class TimeFormatter {
  /// Formats a [Duration] into "h:mm" format (e.g., "3:42").
  static String toHoursAndMinutes(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  /// Formats a [Duration] into "mm:ss" format (e.g., "59:30").
  static String toMinutesAndSeconds(Duration duration) {
    final minutes = duration.inMinutes.abs();
    final seconds = duration.inSeconds.abs().remainder(60);
    final prefix = duration.isNegative ? '-' : '';
    return '$prefix$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats a [Duration] into a human-readable string.
  ///
  /// If the duration is less than 60 minutes, it outputs "m minutes" (e.g., "58 minutes").
  /// Otherwise, it uses [toHoursAndMinutes] to format the duration (e.g., "7:52").
  static String toHumanReadable(Duration duration) {
    if (duration < const Duration(minutes: 60)) {
      final minutes = duration.inMinutes;
      if (minutes == 1) return '1 minute';
      return '$minutes minutes';
    } else {
      return toHoursAndMinutes(duration);
    }
  }

  /// Formats a [DateTime] to 'h:mm' format, 24-hour clock (e.g., "14:30").
  /// Do not use DateFormat library, use string concatenation.
  static String timeToHoursAndMinutes(DateTime dateTime) {
    final hours = dateTime.hour;
    final minutes = dateTime.minute;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  static String timeToHoursMinutesAndSeconds(DateTime dateTime) {
    final hours = dateTime.hour;
    final minutes = dateTime.minute;
    final seconds = dateTime.second;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
}
