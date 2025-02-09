import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkdayTimespanSlider extends ConsumerWidget {
  final TimeOfDay startTime;
  final Duration dayLength;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<Duration> onDayLengthChanged;

  const WorkdayTimespanSlider({
    super.key,
    required this.startTime,
    required this.dayLength,
    required this.onStartTimeChanged,
    required this.onDayLengthChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int startHour = startTime.hour;
    if (startHour >= 24) {
      startHour = 23;
    }
    int endHour = startTime.hour + dayLength.inHours;
    if (endHour > 24) {
      endHour = 24;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Typical Work Day Timespan'),
          subtitle: Text(
              '${startTime.format(context)} - ${TimeOfDay(hour: startTime.hour + dayLength.inHours, minute: startTime.minute).format(context)}'),
        ),
        RangeSlider(
          values: RangeValues(startHour.toDouble(), endHour.toDouble()),
          min: 0,
          max: 24,
          divisions: 24,
          labels: RangeLabels(
              startTime.format(context),
              TimeOfDay(hour: endHour, minute: startTime.minute)
                  .format(context)),
          onChanged: (RangeValues values) {
            var newStartHour = values.start.toInt();
            var newEndHour = values.end.toInt();
            bool startHourWasChange = newStartHour != startHour;
            if (newStartHour == newEndHour) {
              if (startHourWasChange) {
                newStartHour -= 1;
              } else {
                newEndHour += 1;
              }
            }
            if (startHourWasChange) {
              onStartTimeChanged(
                  TimeOfDay(hour: newStartHour, minute: startTime.minute));
            }
            final newDayLength = Duration(hours: newEndHour - newStartHour);
            onDayLengthChanged(newDayLength);
          },
        ),
      ],
    );
  }
}
