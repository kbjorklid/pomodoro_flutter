import 'package:hive/hive.dart';

part 'task_list_dtos.g.dart';

@HiveType(typeId: 20)
class TaskListDto {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final List<TaskDto> tasks;

  TaskListDto({
    required this.id,
    required this.title,
    required this.tasks,
  });
}

@HiveType(typeId: 21)
class TaskDto {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime createdAt;
  @HiveField(3)
  final DateTime? completedAt;

  TaskDto({
    required this.id,
    required this.title,
    required this.createdAt,
    this.completedAt,
  });
}
