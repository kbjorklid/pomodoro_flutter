import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${TimeFormatter.toHumanReadable(duration)}'),
        Slider(
          value: duration.inMinutes.toDouble(),
          min: minDuration.inMinutes.toDouble(),
          max: maxDuration.inMinutes.toDouble(),
          divisions: _divisions(),
          label: TimeFormatter.toHumanReadable(duration),
          onChanged: (value) {
            onChanged(Duration(minutes: value.toInt()));
          },
        ),
      ],
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
