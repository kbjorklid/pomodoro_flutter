// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerSessionAdapterAdapter extends TypeAdapter<TimerSessionAdapter> {
  @override
  final int typeId = 1;

  @override
  TimerSessionAdapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerSessionAdapter(
      fields[0] as TimerSession,
    );
  }

  @override
  void write(BinaryWriter writer, TimerSessionAdapter obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.session);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerSessionAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
