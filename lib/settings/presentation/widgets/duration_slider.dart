import 'package:flutter/material.dart';

class DurationSlider extends StatelessWidget {
  final String label;
  final Duration duration;
  final Duration minDuration;
  final Duration maxDuration;
  final ValueChanged<Duration> onChanged;

  const DurationSlider({
    super.key,
    required this.label,
    required this.duration,
    required this.minDuration,
    required this.maxDuration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${duration.inMinutes} minutes'),
        Slider(
          value: duration.inMinutes.toDouble(),
          min: minDuration.inMinutes.toDouble(),
          max: maxDuration.inMinutes.toDouble(),
          divisions: (maxDuration.inMinutes - minDuration.inMinutes).toInt(),
          label: '${duration.inMinutes} minutes',
          onChanged: (value) {
            onChanged(Duration(minutes: value.toInt()));
          },
        ),
      ],
    );
  }
}
