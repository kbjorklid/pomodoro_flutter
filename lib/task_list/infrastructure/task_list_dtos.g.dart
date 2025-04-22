// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_dtos.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskListDtoAdapter extends TypeAdapter<TaskListDto> {
  @override
  final int typeId = 20;

  @override
  TaskListDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskListDto(
      id: fields[0] as String,
      title: fields[1] as String,
      tasks: (fields[2] as List).cast<TaskDto>(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskListDto obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskListDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskDtoAdapter extends TypeAdapter<TaskDto> {
  @override
  final int typeId = 21;

  @override
  TaskDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskDto(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[2] as DateTime,
      completedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskDto obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
