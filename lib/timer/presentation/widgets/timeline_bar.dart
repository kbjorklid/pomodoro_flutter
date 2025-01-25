import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../domain/timersession/pause_record.dart';

final _borderRadius = BorderRadius.circular(1);

class TimelineBar extends ConsumerWidget {

  TimelineBar({super.key}) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    final int _startHour = now.hour;
    final int _endHour = min(now.hour + 8, 23);
    final startDateTime = DateTime(now.year, now.month, now.day, _startHour);
    final endDateTime = DateTime(now.year, now.month, now.day, _endHour);
    final timeRange = DateTimeRange(start: startDateTime, end: endDateTime);

    final sessionsAsync = ref.watch(todaySessionsProvider);

    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        color: Colors.grey[200],
      ),
      child: sessionsAsync.when(
        data: (sessions) => _buildTimeline(sessions, timeRange),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error loading timeline: $error')),
      ),
    );
  }

  Widget _buildTimeline(List<TimerSession> sessions, DateTimeRange timeRange) {
    return Stack(
      children: [
        // Session segments
        for (final session in sessions) _SessionSegment(session, timeRange),

        // Pause segments
        for (final session in sessions)
          for (final pause in session.pauses) _PauseSegment(pause, timeRange)
      ],
    );
  }
}

class _TimeMarker extends StatelessWidget {
  final int hour;
  final double position;

  const _TimeMarker({required this.hour, required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position,
      child: Text('$hour:00',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          )),
    );
  }
}

abstract class _TimelineSegment extends StatelessWidget {
  final DateTimeRange segmentRange;
  final DateTimeRange fullRange;
  abstract final Color color;

  const _TimelineSegment({
    required this.segmentRange,
    required this.fullRange,
  });

  double _timeToRelativePosition(DateTime time) {
    final totalMinutes = fullRange.duration.inMinutes;
    final minutesFromStart = time.difference(fullRange.start).inMinutes;
    if (totalMinutes == 0) return 0;
    return (minutesFromStart / totalMinutes).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final left = _timeToRelativePosition(segmentRange.start);
    final right = _timeToRelativePosition(segmentRange.end);
    final relativeWidth = right - left;
    if (relativeWidth <= 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: left * MediaQuery.of(context).size.width),
      child: FractionallySizedBox(
        widthFactor: relativeWidth,
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: _borderRadius,
          ),
        ),
      ),
    );
  }
}

class _SessionSegment extends _TimelineSegment {
  late final TimerType _timerType;
  late final bool _completed;

  _SessionSegment(TimerSession session, DateTimeRange fullRange)
      : super(
            segmentRange:
                DateTimeRange(start: session.startedAt, end: session.endedAt),
            fullRange: fullRange) {
    _timerType = session.sessionType;
    _completed = session.isCompleted;
  }

  @override
  Color get color {
    if (_timerType == TimerType.work) {
      return _completed ? Colors.teal : Colors.grey[800]!;
    }
    return Colors.green;
  }
}

class _PauseSegment extends _TimelineSegment {
  _PauseSegment(PauseRecord pause, DateTimeRange fullRange)
      : super(
            segmentRange:
                DateTimeRange(start: pause.pausedAt, end: pause.resumedAt),
            fullRange: fullRange);

  @override
  Color get color => Colors.lightBlue[300]!;
}
