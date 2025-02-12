// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerSessionDTOAdapter extends TypeAdapter<TimerSessionDTO> {
  @override
  final int typeId = 1;

  @override
  TimerSessionDTO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerSessionDTO(
      sessionTypeCode: fields[0] as int,
      startedAt: fields[1] as DateTime,
      endedAt: fields[2] as DateTime,
      deleted: fields[5] == null ? false : fields[5] as bool,
      pauses: (fields[3] as List).cast<PauseRecordDTO>(),
      totalDuration: fields[4] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, TimerSessionDTO obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sessionTypeCode)
      ..writeByte(1)
      ..write(obj.startedAt)
      ..writeByte(2)
      ..write(obj.endedAt)
      ..writeByte(3)
      ..write(obj.pauses)
      ..writeByte(4)
      ..write(obj.totalDuration)
      ..writeByte(5)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerSessionDTOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
