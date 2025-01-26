import 'package:hive/hive.dart';
import 'package:pomodoro_app2/timer/domain/timersession/pause_record.dart';

part 'pause_record_dto.g.dart';

@HiveType(typeId: 2)
class PauseRecordDTO {
  @HiveField(0)
  final DateTime pausedAt;
  @HiveField(1)
  final DateTime resumedAt;

  PauseRecordDTO({
    required this.pausedAt,
    required this.resumedAt,
  });

  factory PauseRecordDTO.fromDomain(PauseRecord record) => PauseRecordDTO(
        pausedAt: record.pausedAt,
        resumedAt: record.resumedAt,
      );

  PauseRecord toDomain() => PauseRecord(
        pausedAt: pausedAt,
        resumedAt: resumedAt,
      );

  @override
  String toString() {
    return 'PauseRecordDTO{pausedAt: $pausedAt, resumedAt: $resumedAt}';
  }
}
