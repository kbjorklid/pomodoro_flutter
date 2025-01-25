import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_history_updated_event.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

import '../../domain/timersession/pause_record.dart';

final _borderRadius = BorderRadius.circular(1);

Logger logger = Logger();

class TimelineBar extends ConsumerWidget {

  TimelineBar({super.key}) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for history update events and refresh data
    DomainEventBus.of<TimerHistoryUpdatedEvent>().listen((event) {
      ref.invalidate(todaySessionsProvider);
    });

    final sessionsAsync = ref.watch(todaySessionsProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = screenWidth * 0.05;

    return Container(
      width: double.infinity,
      height: 30,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: horizontalMargin),
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        color: Colors.grey[200],
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        return sessionsAsync.when(
            data: (sessions) => _buildTimeline(sessions, width),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => throw error);
      }),
    );
  }

  Widget _buildTimeline(List<TimerSession> sessions, double timelineWidth) {
    DateTime now = DateTime.now();
    DateTime startDateTime;
    DateTime endDateTime;
    if (sessions.isEmpty) {
      startDateTime = DateTime(now.year, now.month, now.day, now.hour);
      endDateTime = startDateTime.add(Duration(hours: 8));
    } else {
      sessions.sort((a, b) => a.startedAt.compareTo(b.startedAt));
      var startHour = sessions.first.startedAt.hour;
      startDateTime = DateTime(now.year, now.month, now.day, startHour);
      endDateTime = DateTime(now.year, now.month, now.day, now.hour)
          .add(Duration(hours: 1));
    }
    logger.d("Start: $startDateTime, End: $endDateTime");

    final timeRange = DateTimeRange(start: startDateTime, end: endDateTime);
    return Stack(
      children: _children(sessions, timeRange, timelineWidth),
    );
  }

  List<Widget> _children(List<TimerSession> sessions,
      DateTimeRange timeBarRange, double timelineWidth) {
    final children = <Widget>[];
    for (final session in sessions) {
      _SegmentPosition segmentPosition = _SegmentPosition(
          segmentRange: session.range,
          timeBarRange: timeBarRange,
          timelinePixelWidth: timelineWidth);
      if (segmentPosition.isEmpty) continue;

      logger.d("Session: $session\n    SegmentPosition: $segmentPosition");
      children.add(
          _SessionSegment(segmentPosition: segmentPosition, session: session));
    }
    // Add pauses at the end, on top of everything else.
    for (final session in sessions) {
      for (final pause in session.pauses) {
        _SegmentPosition segmentPosition = _SegmentPosition(
            segmentRange: pause.range,
            timeBarRange: timeBarRange,
            timelinePixelWidth: timelineWidth);
        children
            .add(_PauseSegment(segmentPosition: segmentPosition, pause: pause));
      }
    }
    return children;
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
  final _SegmentPosition segmentPosition;
  abstract final Color color;

  const _TimelineSegment({required this.segmentPosition});

  @override
  Widget build(BuildContext context) {
    if (segmentPosition.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(left: segmentPosition.left),
      child: Container(
        width: segmentPosition.width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: _borderRadius,
        ),
      ),
    );
  }
}

class _SessionSegment extends _TimelineSegment {
  final TimerSession session;

  const _SessionSegment(
      {required super.segmentPosition, required this.session});

  @override
  Color get color {
    if (session.sessionType == TimerType.work) {
      return session.isCompleted ? Colors.teal : Colors.grey[800]!;
    }
    return Colors.green;
  }
}

class _PauseSegment extends _TimelineSegment {
  final PauseRecord pause;

  const _PauseSegment({required super.segmentPosition, required this.pause});

  @override
  Color get color => Colors.lightBlue[300]!;
}

class _SegmentPosition {
  late final double relativeStart;
  late final double relativeEnd;
  final double timelinePixelWidth;

  double get left => relativeStart * timelinePixelWidth;

  double get right => relativeEnd * timelinePixelWidth;

  double get width => max(right - left, 0);

  bool get isEmpty => width < 0.00001;

  _SegmentPosition(
      {required DateTimeRange segmentRange,
      required DateTimeRange timeBarRange,
      required this.timelinePixelWidth}) {
    relativeStart = _startPos(segmentRange, timeBarRange);
    relativeEnd = _endPos(segmentRange, timeBarRange);
  }

  double _startPos(DateTimeRange sessionRange, DateTimeRange fullTimeRange) {
    final totalMinutes = fullTimeRange.duration.inMinutes;
    final minutesFromStart =
        sessionRange.start.difference(fullTimeRange.start).inMinutes;
    if (totalMinutes == 0) return 0;
    return (minutesFromStart / totalMinutes).clamp(0.0, 1.0);
  }

  double _endPos(DateTimeRange sessionRange, DateTimeRange fullTimeRange) {
    final totalMinutes = fullTimeRange.duration.inMinutes;
    final minutesFromStart =
        sessionRange.end.difference(fullTimeRange.start).inMinutes;
    if (totalMinutes == 0) return 0;
    return (minutesFromStart / totalMinutes).clamp(0.0, 1.0);
  }

  @override
  String toString() {
    if (isEmpty) return 'SegmentPosition{isEmpty: true}';
    return 'SegmentPosition{relativeStart: ${relativeStart.toStringAsFixed(4)}, '
        'relativeEnd: ${relativeEnd.toStringAsFixed(4)}, timelinePixelWidth: $timelinePixelWidth, '
        'left: ${left.toStringAsFixed(2)}, right: ${right.toStringAsFixed(2)}, '
        'width: ${width.toStringAsFixed(2)}, isEmpty: $isEmpty}';
  }
}
