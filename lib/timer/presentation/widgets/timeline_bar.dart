import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_history_updated_event.dart';
import 'package:pomodoro_app2/core/domain/events/timer_running_events.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/core/presentation/colors.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';

final _borderRadius = BorderRadius.circular(1);
final _logger = Logger();

class _CurrentlyRunningSession {
  StreamSubscription? _runtimeEventSubscription;
  StreamSubscription? _timerStoppedSubscription;
  TimerState? state;
  _SessionSegment? _currentSegment;
  List<_PauseSegment> _pauseSegments = [];

  _SessionSegment? getCurrentSegment(
      DateTimeRange timebarRange, double timelinePixelWidth) {
    _updateCurrentSegment(timebarRange, timelinePixelWidth);
    return _currentSegment;
  }

  List<_PauseSegment> getPauseSegments(
      DateTimeRange timebarRange, double timelinePixelWidth) {
    _updatePauseSegments(timebarRange, timelinePixelWidth);
    return _pauseSegments;
  }

  _CurrentlyRunningSession() {
    _runtimeEventSubscription =
        DomainEventBus.of<TimerRuntimeEvent>().listen((event) {
      if (event.runtimeType == TimerSecondsChangedEvent) return;
      state = event.timerState;
      _invalidateSegments();
    });
    _timerStoppedSubscription =
        DomainEventBus.of<TimerStoppedEvent>().listen((event) {
      state = null;
      _invalidateSegments();
    });
  }

  void dispose() {
    _runtimeEventSubscription?.cancel();
    _timerStoppedSubscription?.cancel();
  }

  void _updateCurrentSegment(DateTimeRange timeBarRange,
      double timelinePixelWidth,
      [DateTime? now]) {
    TimerState? state = this.state;
    if (state == null || state.startedAt == null) {
      _invalidateSegments();
    } else {
      now ??= DateTime.now();
      DateTime startTime = state.startedAt!;
      DateTime endTime = now;
      DateTimeRange segmentRange =
          DateTimeRange(start: startTime, end: endTime);
      final segmentPosition = _SegmentPosition(
          segmentRange: segmentRange,
          timeBarRange: timeBarRange,
          timelinePixelWidth: timelinePixelWidth);
      _currentSegment =
          _SessionSegment.fromValues(segmentPosition, state.timerType, true);
    }
  }

  void _updatePauseSegments(DateTimeRange timeBarRange,
      double timelinePixelWidth,
      [DateTime? now]) {
    TimerState? state = this.state;
    if (state == null || state.startedAt == null) {
      _invalidateSegments();
    } else {
      now ??= DateTime.now();
      _pauseSegments = state.pauses.map((pause) {
        final segmentPosition = _SegmentPosition(
            segmentRange: pause.range,
            timeBarRange: timeBarRange,
            timelinePixelWidth: timelinePixelWidth);
        return _PauseSegment(segmentPosition: segmentPosition, pause: pause);
      }).toList();
      if (state.pausedAt != null) {
        final pauseSegment = _PauseSegment(
            segmentPosition: _SegmentPosition(
                segmentRange: DateTimeRange(start: state.pausedAt!, end: now),
                timeBarRange: timeBarRange,
                timelinePixelWidth: timelinePixelWidth),
            pause: PauseRecord(pausedAt: state.pausedAt!, resumedAt: now));
        _pauseSegments.add(pauseSegment);
      }
    }
  }

  void _invalidateSegments() {
    _currentSegment = null;
    _pauseSegments = [];
  }
}

class TimelineBar extends ConsumerStatefulWidget {
  const TimelineBar({super.key});

  @override
  ConsumerState<TimelineBar> createState() => _TimelineBarState();
}

class _TimelineBarState extends ConsumerState<TimelineBar> {
  final _CurrentlyRunningSession _currentSession = _CurrentlyRunningSession();
  StreamSubscription? _timerHistorySubscription;
  StreamSubscription? _timerRuntimeSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _timerHistorySubscription =
        DomainEventBus.of<TimerHistoryUpdatedEvent>().listen((event) {
      _refresh();
    });
    _timerRuntimeSubscription =
        DomainEventBus.of<TimerRuntimeEvent>().listen((event) {
      _refresh();
    });
    // Add periodic refresh timer
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  void _refresh() {
    ref.invalidate(todaySessionsProvider);
    setState(() {});
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _timerHistorySubscription?.cancel();
    _timerRuntimeSubscription?.cancel();
    _currentSession.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    final timeBarRange = _getTimeBarRange(sessions, now);
    _logger.d("Start: ${timeBarRange.start}, End: ${timeBarRange.end}");
    return Stack(
      children: _children(sessions, timeBarRange, timelineWidth),
    );
  }

  DateTimeRange _getTimeBarRange(List<TimerSession> sessions, [DateTime? now]) {
    now ??= DateTime.now();
    var end = now;
    DateTime start;
    if (sessions.isEmpty) {
      start = end.subtract(const Duration(hours: 1));
    } else {
      sessions.sort((a, b) => a.startedAt.compareTo(b.startedAt));
      start = sessions.first.startedAt;
      if (end.difference(start).inMinutes < 60) {
        start = end.subtract(const Duration(hours: 1));
      }
    }
    DateTime? currentSessionStart = _currentSession.state?.startedAt;
    if (currentSessionStart != null && currentSessionStart.isBefore(start)) {
      start = currentSessionStart;
    }
    return new DateTimeRange(start: start, end: end);
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

      _logger.d("Session: $session\n    SegmentPosition: $segmentPosition");
      children.add(
          _SessionSegment(segmentPosition: segmentPosition, session: session));
    }
    _SessionSegment? current =
        _currentSession.getCurrentSegment(timeBarRange, timelineWidth);
    if (current != null) {
      children.add(current);
    }
    // Add pauses at the end, on top of everything else.
    for (final session in sessions) {
      for (final pause in session.pauses) {
        _SegmentPosition segmentPosition = _SegmentPosition(
            segmentRange: pause.range,
            timeBarRange: timeBarRange,
            timelinePixelWidth: timelineWidth);

        _logger.d("Pause: $pause\n    SegmentPosition: $segmentPosition");
        children
            .add(_PauseSegment(segmentPosition: segmentPosition, pause: pause));
      }
    }
    List<_PauseSegment> currentPauseSegments =
        _currentSession.getPauseSegments(timeBarRange, timelineWidth);
    children.addAll(currentPauseSegments);
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
        width: max(1, segmentPosition.width),
        decoration: BoxDecoration(
          color: color,
          borderRadius: _borderRadius,
        ),
      ),
    );
  }
}

class _SessionSegment extends _TimelineSegment {
  late final TimerType _timerType;
  late final bool _isCompleted;

  _SessionSegment(
      {required super.segmentPosition, required TimerSession session}) {
    _timerType = session.sessionType;
    _isCompleted = session.isCompleted;
  }

  _SessionSegment.fromValues(
      _SegmentPosition position, TimerType timerType, bool isCompleted)
      : super(segmentPosition: position) {
    _timerType = timerType;
    _isCompleted = isCompleted;
  }

  @override
  Color get color {
    if (_timerType == TimerType.work) {
      return _isCompleted ? AppColors.work : AppColors.workIncomplete;
    }
    return AppColors.rest;
  }
}

class _PauseSegment extends _TimelineSegment {
  final PauseRecord pause;

  const _PauseSegment({required super.segmentPosition, required this.pause});

  @override
  Color get color => Color(0x88ffffff);
}

class _SegmentPosition {
  late final double relativeStart;
  late final double relativeEnd;
  final double timelinePixelWidth;

  double get left => relativeStart * timelinePixelWidth;

  double get right => relativeEnd * timelinePixelWidth;

  double get width => max(right - left, 0);

  bool get isEmpty => width == 0;

  _SegmentPosition(
      {required DateTimeRange segmentRange,
      required DateTimeRange timeBarRange,
      required this.timelinePixelWidth}) {
    relativeStart = _startPos(segmentRange, timeBarRange);
    relativeEnd = _endPos(segmentRange, timeBarRange);
  }

  double _startPos(DateTimeRange sessionRange, DateTimeRange fullTimeRange) {
    final totalSeconds = fullTimeRange.duration.inSeconds;
    final secondsFromStart =
        sessionRange.start.difference(fullTimeRange.start).inSeconds;
    if (totalSeconds == 0) return 0;
    return (secondsFromStart / totalSeconds).clamp(0.0, 1.0);
  }

  double _endPos(DateTimeRange sessionRange, DateTimeRange fullTimeRange) {
    final totalSeconds = fullTimeRange.duration.inSeconds;
    final secondsFromStart =
        sessionRange.end.difference(fullTimeRange.start).inSeconds;
    if (totalSeconds == 0) return 0;
    return (secondsFromStart / totalSeconds).clamp(0.0, 1.0);
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
