import 'package:flutter/material.dart';
import 'package:pomodoro_app2/settings/presentation/widgets/settings_list_tile.dart';

import '../../../core/domain/time_formatter.dart';
class DurationSlider extends StatelessWidget {
  final String label;
  final Duration duration;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration step;
  final ValueChanged<Duration> onChanged;

  const DurationSlider({
    super.key,
    required this.label,
    required this.duration,
    required this.minDuration,
    required this.maxDuration,
    required this.onChanged,
    this.step = const Duration(minutes: 1),
  });

  @override
  Widget build(BuildContext context) {
    return SettingsListTile(
      title: '$label: ${TimeFormatter.toHumanReadable(duration)}',
      below: Slider(
        value: duration.inMinutes.toDouble(),
          min: minDuration.inMinutes.toDouble(),
          max: maxDuration.inMinutes.toDouble(),
          divisions: _divisions(),
          label: TimeFormatter.toHumanReadable(duration),
          onChanged: (value) {
            onChanged(Duration(minutes: value.toInt()));
          },
        ),
    );
  }
  
  int _divisions() {
    int minutes = maxDuration.inMinutes - minDuration.inMinutes;
    if (step == Duration(minutes: 1)) {
      return minutes;
    }
    return (minutes / step.inMinutes).toInt();
  }
}
