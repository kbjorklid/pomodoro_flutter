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
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/timer/application/get_todays_timer_sessions_use_case.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';
import 'package:pomodoro_app2/timer/presentation/providers/get_todays_timer_sessions_use_case_provider.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_details_dialog.dart';

// Constants should be declared before the class.
final BorderRadius _borderRadius = BorderRadius.circular(1);
final Logger _logger = Logger();

class TimelineBar extends ConsumerStatefulWidget {
  const TimelineBar({
    super.key,
    this.targetDate,
    this.timerSessions,
  });

  final DateTime?
      targetDate; // Optional date for historical data.  If null, defaults to today.
  final List<ClosedTimerSession>?
      timerSessions; //Optional session list. If null, defaults to todays session

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

    // Only subscribe to events if we're showing today's timeline.
    if (widget.targetDate == null) {
      _timerHistorySubscription = DomainEventBus.of<TimerHistoryUpdatedEvent>()
          .listen(_onTimerHistoryUpdated);
      _timerRuntimeSubscription =
          DomainEventBus.of<TimerRuntimeEvent>().listen(_onTimerRuntimeEvent);

      // Add periodic refresh timer only for today's timeline
      _refreshTimer =
          Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
    }
  }

  // extracted event handler methods
  void _onTimerHistoryUpdated(TimerHistoryUpdatedEvent event) {
    _refresh();
  }

  void _onTimerRuntimeEvent(TimerRuntimeEvent event) {
    _refresh();
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
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: horizontalMargin),
      child: FutureBuilder<_TimelineData>(
        future: _getTimelineData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final timelineData = snapshot.data ?? _TimelineData.empty();
          final timeBarRange = _getTimeBarRange(timelineData);

          return _buildTimelineContainer(timeBarRange, timelineData);
        },
      ),
    );
  }

  /*
  Widget _buildTimelineContainer(
      DateTimeRange timeBarRange, _TimelineData timelineData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[350]!),
      ),
      child: _buildMainTimeline(timelineData, timeBarRange),
    );
  }*/

  Widget _buildTimelineContainer(
      DateTimeRange timeBarRange, _TimelineData timelineData) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 18, right: 18),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: _borderRadius,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[350]!),
                ),
                height: 30,
                child: _buildMainTimeline(timelineData, timeBarRange))),
        Container(
            height: 20,
            child: _buildAnnotationsBelowTimeline(timelineData, timeBarRange)),
      ],
    );
  }

  Stack _buildAnnotationsBelowTimeline(
      _TimelineData timelineData, DateTimeRange timeBarRange) {
    return Stack(
      children: [
        _TimelineTimeLabel(
          time: timeBarRange.start,
          position: _TimeLabelPosition.start,
        ),
        _TimelineTimeLabel(
          time: timeBarRange.end,
          position: _TimeLabelPosition.end,
        ),
      ],
    );
  }

  Widget _buildMainTimeline(
      _TimelineData timelineData, DateTimeRange timeBarRange) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            _buildTimelineSegments(timelineData, timeBarRange, width),
            if (widget.targetDate == null ||
                DateUtils.isSameDay(widget.targetDate, DateTime.now()))
              _buildCurrentTimeMarker(timeBarRange, width),
          ],
        );
      },
    );
  }

  Widget _buildCurrentTimeMarker(DateTimeRange timeBarRange, double width) {
    final now = DateTime.now();
    final relativePosition = _calculateRelativePosition(now, timeBarRange);
    final markerLeft = relativePosition * width;

    return Positioned(
      left: markerLeft,
      bottom: 0,
      child: Container(
        width: 2,
        height: 15, // 50% of the timeline bar height (30)
        color: Colors.black,
      ),
    );
  }

  double _calculateRelativePosition(
      DateTime time, DateTimeRange fullTimeRange) {
    final totalSeconds = fullTimeRange.duration.inSeconds;
    final secondsFromStart = time.difference(fullTimeRange.start).inSeconds;
    if (totalSeconds == 0) return 0;
    return (secondsFromStart / totalSeconds).clamp(0.0, 1.0);
  }

  Widget _buildTimelineSegments(_TimelineData timelineData,
      DateTimeRange timeBarRange, double timelineWidth) {
    _logger.d(
        "TimeBarRange Start: ${timeBarRange.start}, End: ${timeBarRange.end}");
    return Stack(
      children:
          _buildTimelineChildren(timelineData, timeBarRange, timelineWidth),
    );
  }

  List<Widget> _buildTimelineChildren(_TimelineData timelineData,
      DateTimeRange timeBarRange, double timelineWidth) {
    final now = DateTime.now();
    final children = <Widget>[];

    if (timelineData.typicalWorkDayStart != null &&
        timelineData.typicalWorkDayLength != null) {
      children.add(
        _WorkDaySegment(
            workdayStart: timelineData.typicalWorkDayStart!,
            workdayDuration: timelineData.typicalWorkDayLength!,
            timeBarRange: timeBarRange,
            timelinePixelWidth: timelineWidth),
      );
    }

    for (final session in timelineData.sessions) {
      final range = session.range;
      final segmentPosition = _SegmentPosition(
          segmentRange: range,
          timeBarRange: timeBarRange,
          timelinePixelWidth: timelineWidth);

      if (segmentPosition.isEmpty) continue;

      _logger.d("Session: $session\n    SegmentPosition: $segmentPosition");

      final onTap = session.isEnded
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
        final segmentPosition = _SegmentPosition(
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

  DateTimeRange _getTimeBarRange(_TimelineData timelineData, [DateTime? now]) {
    now ??= widget.targetDate ??
        DateTime.now(); // Use the widget's date, or today if null
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

  void _showTimerDetailsPopup(
      BuildContext context, ClosedTimerSession session) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimerDetailsDialog(
          session: session,
          onDelete: (session) async {
            await ref.read(timerSessionRepositoryProvider).delete(session.key);
          },
          onUndoDelete: (session) async {
            await ref
                .read(timerSessionRepositoryProvider)
                .undelete(session.key);
          },
        );
      },
    );
  }

  Future<_TimelineData> _getTimelineData() async {
    final settings = ref.read(settingsRepositoryProvider);
    final DateTime targetDate = widget.targetDate ?? DateTime.now();
    final List<ClosedTimerSession>? timerSessions = widget.timerSessions;

    List<dynamic> results;

    if (timerSessions != null) {
      //Use timerSessions if specified
      results = await Future.wait([
        settings.getTypicalWorkDayStart(),
        settings.getTypicalWorkDayLength(),
        Future.value(timerSessions),
        settings.isAlwaysShowWorkdayTimespanInTimeline(),
      ]);
    } else {
      //Load timerSessions for targetDate
      results = await Future.wait([
        settings.getTypicalWorkDayStart(),
        settings.getTypicalWorkDayLength(),
        _todaysTimerSessionsUseCase.getTodaysSessions(targetDate),
        settings.isAlwaysShowWorkdayTimespanInTimeline(),
      ]);
    }

    final alwaysShowWorkdayTimespan = results[3] as bool;
    final typicalWorkDayStart = results[0] as TimeOfDay;
    final typicalWorkDayLength = results[1] as Duration;

    DateTimeRange? minimumRange;

    if (alwaysShowWorkdayTimespan) {
      DateTime workdayStartDateTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          typicalWorkDayStart.hour,
          typicalWorkDayStart.minute);
      DateTime workdayEndDateTime =
          workdayStartDateTime.add(typicalWorkDayLength);
      minimumRange =
          DateTimeRange(start: workdayStartDateTime, end: workdayEndDateTime);
    }

    return _TimelineData(
      sessions: results[2] as List<ClosedTimerSession>,
      typicalWorkDayStart: typicalWorkDayStart,
      typicalWorkDayLength: typicalWorkDayLength,
      minimumRange: minimumRange,
    );
  }
}

class _TimelineData {
  final List<ClosedTimerSession> sessions;
  final TimeOfDay? typicalWorkDayStart;
  final Duration? typicalWorkDayLength;
  final DateTimeRange? minimumRange;

  _TimelineData({
    required this.sessions,
    required this.typicalWorkDayStart,
    required this.typicalWorkDayLength,
    this.minimumRange,
  });

  _TimelineData.empty()
      : this(
            sessions: [],
            typicalWorkDayStart: null,
            typicalWorkDayLength: null,
            minimumRange: null);
}

class _WorkDaySegment extends _TimelineSegment {
  _WorkDaySegment._internal({required super.segmentPosition});

  factory _WorkDaySegment({
    required TimeOfDay workdayStart,
    required Duration workdayDuration,
    required DateTimeRange timeBarRange,
    required double timelinePixelWidth,
  }) {
    DateTime workdayStartDateTime = DateTime(
        timeBarRange.start.year,
        timeBarRange.start.month,
        timeBarRange.start.day,
        workdayStart.hour,
        workdayStart.minute);
    DateTime workdayEndDateTime = workdayStartDateTime.add(workdayDuration);
    DateTime dayEnd = DateTime(timeBarRange.start.year,
            timeBarRange.start.month, timeBarRange.start.day)
        .add(const Duration(days: 1));
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
  final TimerType _timerType;
  final bool _isCompleted;
  final bool _isRunning;

  _SessionSegment({
    required super.segmentPosition,
    required ClosedTimerSession session,
    VoidCallback? onTap,
  })  : _timerType = session.sessionType,
        _isCompleted = session.isCompleted,
        _isRunning = !session.isEnded,
        super(onTap: onTap);

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

  const _PauseSegment({
    required super.segmentPosition,
    required this.pause,
    VoidCallback? onTap,
  }) : super(onTap: onTap);

  @override
  Color get color => const Color(0x88ffffff);
}

class _SegmentPosition {
  late final double relativeStart;
  late final double relativeEnd;
  final double timelinePixelWidth;

  double get left => relativeStart * timelinePixelWidth;

  double get right => relativeEnd * timelinePixelWidth;

  double get width => max(right - left, 0);

  bool get isEmpty => width == 0;

  _SegmentPosition({
    required DateTimeRange segmentRange,
    required DateTimeRange timeBarRange,
    required this.timelinePixelWidth,
  }) {
    relativeStart =
        _calculateRelativePosition(segmentRange.start, timeBarRange);
    relativeEnd = _calculateRelativePosition(segmentRange.end, timeBarRange);
  }

  double _calculateRelativePosition(
      DateTime time, DateTimeRange fullTimeRange) {
    final totalSeconds = fullTimeRange.duration.inSeconds;
    final secondsFromStart = time.difference(fullTimeRange.start).inSeconds;
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

class _TimelineTimeLabel extends StatelessWidget {
  final DateTime time;
  final _TimeLabelPosition position;

  const _TimelineTimeLabel({required this.time, required this.position});

  @override
  Widget build(BuildContext context) {
    final isStart = position == _TimeLabelPosition.start;
    return Positioned(
      left: isStart ? 0 : null,
      right: isStart ? null : 0,
      top: 0,
      bottom: 0,
      child: Align(
        alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: isStart
              ? const EdgeInsets.only(left: 3.0)
              : const EdgeInsets.only(right: 3.0),
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
