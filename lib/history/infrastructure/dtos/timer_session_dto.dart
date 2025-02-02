import 'package:hive/hive.dart';
import 'package:pomodoro_app2/core/domain/timer_type.dart';
import 'package:pomodoro_app2/history/infrastructure/dtos/pause_record_dto.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

part 'timer_session_dto.g.dart';

@HiveType(typeId: 1)
class TimerSessionDTO {
  @HiveField(0)
  final int sessionTypeCode; // Store enum index
  @HiveField(1)
  final DateTime startedAt;
  @HiveField(2)
  final DateTime endedAt;
  @HiveField(3)
  final List<PauseRecordDTO> pauses;
  @HiveField(4)
  final Duration totalDuration;

  TimerSessionDTO({
    required this.sessionTypeCode,
    required this.startedAt,
    required this.endedAt,
    required this.pauses,
    required this.totalDuration,
  });

  factory TimerSessionDTO.fromDomain(TimerSession session) {
    DateTime? end = session.endedAt;
    if (end == null) {
      throw ArgumentError('Cannot convert an incomplete session to DTO');
    }
    return TimerSessionDTO(
      sessionTypeCode: session.sessionType.index,
      startedAt: session.startedAt,
      endedAt: end,
      pauses: session.pauses.map(PauseRecordDTO.fromDomain).toList(),
      totalDuration: session.totalDuration,
    );
  }

  TimerSession toDomain() => TimerSession(
        sessionType: _timerTypeFromCode(sessionTypeCode),
        startedAt: startedAt,
        endedAt: endedAt,
        pauses: pauses.map((dto) => dto.toDomain()).toList(),
        totalDuration: totalDuration,
      );

  TimerType _timerTypeFromCode(int code) {
    switch (code) {
      case 0:
        return TimerType.work;
      default:
        return TimerType.rest;
    }
  }

  @override
  String toString() {
    return 'TimerSessionDTO{sessionTypeCode: $sessionTypeCode, startedAt: $startedAt, endedAt: $endedAt, pauses: $pauses, totalDuration: $totalDuration}';
  }
}
