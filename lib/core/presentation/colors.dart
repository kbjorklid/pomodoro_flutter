import 'package:flutter/material.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';

/// Application color palette
class AppColors {
  static const peach = Color(0xFFFF7165);
  static const lightPeach = Color(0xFFFFBBB6);
  static const yellow = Color(0xFFF9F9F9);
  static const green = Color(0xFF76D891);
  static const lightGreen = Color(0xFFA9DEB8);
  static const blue = Color(0xFF9DB3E1);
  static const mediumGrey = Color(0xFFBEBEBE);
  static const lightMediumGrey = Color.fromARGB(255, 222, 222, 222);
  static const darkGrey = Color(0xFF666666);
  static const darkerGrey = Color(0xFF333333);
  static const lightGrey = Color(0xFFEEEEEE);

  static const work = peach;
  static const workPaused = lightPeach;
  static const workStopped = mediumGrey;
  static const rest = green;
  static const restPaused = lightGreen;
  static const workIncomplete = mediumGrey;

  static Color timelineWorkdayBackground(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? darkGrey : lightGrey;
  }

  static Color timelineBackground(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? darkerGrey : lightMediumGrey;
  }

  static Color timerTypeColor(TimerType type) {
    if (type == TimerType.work) {
      return work;
    } else {
      return rest;
    }
  }
}
