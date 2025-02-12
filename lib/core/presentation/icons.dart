
import 'package:flutter/material.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/core/presentation/colors.dart';

class AppIcon {
  static const Color _defaultColor = Colors.black;
  static const IconData _completeSessionIconData = Icons.check_circle;
  static const IconData _incompleteSession = Icons.remove_circle;

  static Icon timer(Color? color) {
    color ??= _defaultColor;
    return Icon(Icons.timer, color: color);
  }

  static Icon timerTypeIcon (TimerType type, {Color? color}) {
    color ??= AppColors.timerTypeColor(type);
    switch (type) {
      case TimerType.work:
        return workSession(color);
      case TimerType.shortRest:
        return shortRestSession(color);
      case TimerType.longRest:
        return longRestSession(color);
    }
  }

  static Icon workSession(Color? color) => Icon(Icons.work, color: color ?? _defaultColor);

  static Icon shortRestSession(Color? color) => Icon(Icons.free_breakfast, color: color ?? _defaultColor);

  static Icon longRestSession(Color? color) => Icon(Icons.weekend, color: color ?? _defaultColor);

  static Icon get timerWorkSession =>  timer(AppColors.work);

  static Icon get timerRestSession => timer(AppColors.rest);

  static Icon get completedWorkSession => Icon(_completeSessionIconData, color: AppColors.work);

  static Icon get incompleteWorkSession => Icon(_incompleteSession, color: AppColors.workIncomplete);
}