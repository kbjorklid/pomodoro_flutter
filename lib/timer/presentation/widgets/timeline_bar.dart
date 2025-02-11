import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pomodoro_app2/core/domain/date_time_range_builder.dart';
import 'package:pomodoro_app2/core/domain/events/event_bus.dart';
import 'package:pomodoro_app2/core/domain/events/timer_history_updated_event.dart';
import 'package:pomodoro_app2/core/domain/events/timer_running_events.dart';
import 'package:pomodoro_app2/core/domain/time_formatter.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/core/presentation/colors.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/get_todays_timer_sessions_use_case.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:pomodoro_app2/timer/presentation/providers/get_todays_timer_sessions_use_case_provider.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_details_dialog.dart';

final _borderRadius = BorderRadius.circular(1);
final _logger = Logger();

class TimelineBar extends ConsumerStatefulWidget {
  const TimelineBar({super.key});

  @override
  ConsumerState<TimelineBar> createState() => _TimelineBarState();
}

class _TimelineBarState extends ConsumerState<TimelineBar> {
  StreamSubscription? _timerHistorySubscription;
  StreamSubscription? _timerRuntimeSubscription;
  late final GetTodaysTimerSessionsUseCase _todaysTimerSessionsUseCase;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _todaysTimerSessionsUseCase = ref.read(todaysTimerSessionsUseCaseProvider);
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
    setState(() {});
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _timerHistorySubscription?.cancel();
    _timerRuntimeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = screenWidth * 0.05;

    return Container(
      width: double.infinity,
      height: 30,
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: horizontalMargin),
      child: FutureBuilder<_TimelineData>(
        future: _getTimelineData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final timelineData = snapshot.data ?? _TimelineData.empty();
          final timeBarRange = _getTimeBarRange(timelineData);

          return Container(
            decoration: BoxDecoration(
              borderRadius: _borderRadius,
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey[350]!),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return _buildTimelineSegments(
                        timelineData, timeBarRange, width);
                  },
                ),
                _TimelineTimeLabel(
                  time: timeBarRange.start,
                  position: _TimeLabelPosition.start,
                ),
                _TimelineTimeLabel(
                  time: timeBarRange.end,
                  position: _TimeLabelPosition.end,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineSegments(_TimelineData timelineData,
      DateTimeRange timeBarRange, double timelineWidth) {
    _logger.d(
        "TimeBarRange Start: ${timeBarRange.start}, End: ${timeBarRange.end}");
    return Stack(
      children: _children(timelineData, timeBarRange, timelineWidth),
    );
  }

  DateTimeRange _getTimeBarRange(_TimelineData timelineData, [DateTime? now]) {
    now ??= DateTime.now();
    final rangeBuilder = DateTimeRangeBuilder.forDay(now);

    final minimumRange = timelineData.minimumRange;
    if (minimumRange != null) {
      rangeBuilder.includeRange(minimumRange);
    }
    rangeBuilder.include(now);

    for (final session in timelineData.sessions) {
      rangeBuilder.include(session.startedAt);
      rangeBuilder.include(session.timerRangeEnd);
    }
    rangeBuilder.ensureMinDurationExpandingToPast(
        amount: const Duration(hours: 1));

    return rangeBuilder.getDateTimeRange();
  }

  DateTime _startOfToday([DateTime? now]) {
    now ??= DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  List<Widget> _children(_TimelineData timelineData, DateTimeRange timeBarRange,
      double timelineWidth,
      [DateTime? now]) {
    now ??= DateTime.now();
    final children = <Widget>[];
    if (timelineData.typicalWorkDayStart != null &&
        timelineData.typicalWorkDayLength != null) {
      final workdaySegment = _WorkDaySegment(
          workdayStart: timelineData.typicalWorkDayStart!,
          workdayDuration: timelineData.typicalWorkDayLength!,
          timeBarRange: timeBarRange,
          timelinePixelWidth: timelineWidth);
      children.add(workdaySegment);
    }
    for (final session in timelineData.sessions) {
      DateTimeRange range =
          session.range ?? DateTimeRange(start: session.startedAt, end: now);
      _SegmentPosition segmentPosition = _SegmentPosition(
          segmentRange: range,
          timeBarRange: timeBarRange,
          timelinePixelWidth: timelineWidth);
      if (segmentPosition.isEmpty) continue;

      _logger.d("Session: $session\n    SegmentPosition: $segmentPosition");
      VoidCallback? onTap = session.isEnded
          ? () {
              _showTimerDetailsPopup(context, session);
            }
          : null;
      children.add(_SessionSegment(
        segmentPosition: segmentPosition,
        session: session,
        onTap: onTap,
      ));
    }
    // Add pauses at the end, on top of everything else.
    for (final session in timelineData.sessions) {
      for (final pause in session.pauses) {
        _SegmentPosition segmentPosition = _SegmentPosition(
            segmentRange: pause.range,
            timeBarRange: timeBarRange,
            timelinePixelWidth: timelineWidth);

        _logger.d("Pause: $pause\n    SegmentPosition: $segmentPosition");
        children.add(_PauseSegment(
          segmentPosition: segmentPosition,
          pause: pause,
        ));
      }
    }
    return children;
  }

  void _showTimerDetailsPopup(
      BuildContext context, ClosedTimerSession session) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimerDetailsDialog(session: session);
      },
    );
  }

  Future<_TimelineData> _getTimelineData() async {
    final settings = ref.read(settingsRepositoryProvider);
    final results = await Future.wait([
      settings.getTypicalWorkDayStart(),
      settings.getTypicalWorkDayLength(),
      _todaysTimerSessionsUseCase.getTodaysSessions(),
      settings.isAlwaysShowWorkdayTimespanInTimeline(),
    ]);

    final alwaysShowWorkdayTimespan = results[3] as bool;
    final typicalWorkDayStart = results[0] as TimeOfDay;
    final typicalWorkDayLength = results[1] as Duration;

    if (alwaysShowWorkdayTimespan) {
      DateTime workdayStartDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          typicalWorkDayStart.hour,
          typicalWorkDayStart.minute);
      DateTime workdayEndDateTime =
          workdayStartDateTime.add(typicalWorkDayLength);
      DateTimeRange minimumRange =
          DateTimeRange(start: workdayStartDateTime, end: workdayEndDateTime);
      return _TimelineData(
          sessions: results[2] as List<ClosedTimerSession>,
          typicalWorkDayStart: typicalWorkDayStart,
          typicalWorkDayLength: typicalWorkDayLength,
          minimumRange: minimumRange);
    }
    return _TimelineData(
        sessions: results[2] as List<ClosedTimerSession>,
        typicalWorkDayStart: typicalWorkDayStart,
        typicalWorkDayLength: typicalWorkDayLength,
        minimumRange: null);
  }
}

class _TimelineData {
  final List<ClosedTimerSession> sessions;
  final TimeOfDay? typicalWorkDayStart;
  final Duration? typicalWorkDayLength;
  final DateTimeRange? minimumRange;

  _TimelineData(
      {required this.sessions,
      required this.typicalWorkDayStart,
      required this.typicalWorkDayLength,
      this.minimumRange});

  _TimelineData.empty()
      : this(
            sessions: [],
            typicalWorkDayStart: null,
            typicalWorkDayLength: null,
            minimumRange: null);
}

class _WorkDaySegment extends _TimelineSegment {
  _WorkDaySegment._internal({required super.segmentPosition});

  factory _WorkDaySegment(
      {required TimeOfDay workdayStart,
      required Duration workdayDuration,
      required DateTimeRange timeBarRange,
      required double timelinePixelWidth}) {
    DateTime workdayStartDateTime = DateTime(
        timeBarRange.start.year,
        timeBarRange.start.month,
        timeBarRange.start.day,
        workdayStart.hour,
        workdayStart.minute);
    DateTime workdayEndDateTime = workdayStartDateTime.add(workdayDuration);
    DateTime dayEnd = DateTime(timeBarRange.start.year,
            timeBarRange.start.month, timeBarRange.start.day)
        .add(Duration(days: 1));
    if (workdayEndDateTime.isAfter(dayEnd)) {
      workdayEndDateTime = dayEnd;
    }
    DateTimeRange workdayRange =
        DateTimeRange(start: workdayStartDateTime, end: workdayEndDateTime);
    final pos = _SegmentPosition(
        segmentRange: workdayRange,
        timeBarRange: timeBarRange,
        timelinePixelWidth: timelinePixelWidth);
    return _WorkDaySegment._internal(segmentPosition: pos);
  }

  @override
  Color get color => AppColors.timelineWorkdayBackground;
}

abstract class _TimelineSegment extends StatelessWidget {
  final _SegmentPosition segmentPosition;
  abstract final Color color;
  final VoidCallback? onTap;

  const _TimelineSegment({required this.segmentPosition, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (segmentPosition.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(left: segmentPosition.left),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: max(1, segmentPosition.width),
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
  late final bool _isCompleted;
  late final bool _isRunning;

  _SessionSegment({
    required super.segmentPosition,
    required ClosedTimerSession session,
    VoidCallback? onTap,
  }) : super(onTap: onTap) {
    _timerType = session.sessionType;
    _isCompleted = session.isCompleted;
    _isRunning = !session.isEnded;
  }

  @override
  Color get color {
    if (_timerType == TimerType.work) {
      return _isCompleted || _isRunning
          ? AppColors.work
          : AppColors.workIncomplete;
    }
    return AppColors.rest;
  }
}

class _PauseSegment extends _TimelineSegment {
  final PauseRecord pause;

  const _PauseSegment(
      {required super.segmentPosition,
      required this.pause,
      VoidCallback? onTap})
      : super(onTap: onTap);

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

/// Widget for displaying time labels at the ends of the timeline bar.
class _TimelineTimeLabel extends StatelessWidget {
  final DateTime time;
  final _TimeLabelPosition position;

  const _TimelineTimeLabel({required this.time, required this.position});

  @override
  Widget build(BuildContext context) {
    double? left = position == _TimeLabelPosition.start ? 0 : null;
    double? right = position == _TimeLabelPosition.end ? 0 : null;
    return Positioned(
      left: left,
      right: right,
      top: 0,
      bottom: 0,
      child: Align(
        alignment: position == _TimeLabelPosition.start
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Padding(
          padding: position == _TimeLabelPosition.start
              ? const EdgeInsets.only(left: 6.0)
              : const EdgeInsets.only(right: 6.0),
          child: Text(
            TimeFormatter.timeToHoursAndMinutes(time),
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

enum _TimeLabelPosition { start, end }
