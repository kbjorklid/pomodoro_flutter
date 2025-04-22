import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app2/task_list/domain/task.dart';
import 'package:pomodoro_app2/task_list/domain/task_list.dart';
import 'package:pomodoro_app2/task_list/domain/task_list_repository.dart';
import 'package:pomodoro_app2/task_list/infrastructure/task_list_dtos.dart';

class TaskListRepositoryImpl implements TaskListRepository {
  final Box<TaskListDto> _taskListDtoBox;

  TaskListRepositoryImpl(this._taskListDtoBox);

  @override
  Future<TaskList> create(TaskList taskList) async {
    final taskListDto = _toDto(taskList);
    await _taskListDtoBox.put(taskListDto.id, taskListDto);
    return taskList;
  }

  @override
  Future<TaskList?> getById(TaskListId id) async {
    final taskListDto = _taskListDtoBox.get(id.value);
    return taskListDto == null ? null : _toDomain(taskListDto);
  }

  @override
  Future<void> save(TaskList taskList) async {
    final taskListDto = _toDto(taskList);
    await _taskListDtoBox.put(taskListDto.id, taskListDto);
  }

  @override
  Future<void> update(TaskList taskList) async {
    final taskListDto = _toDto(taskList);
    await _taskListDtoBox.put(taskListDto.id, taskListDto);
  }

  TaskListDto _toDto(TaskList taskList) {
    return TaskListDto(
      id: taskList.id.value,
      title: taskList.title,
      tasks: taskList.tasks.map(_taskToDto).toList(),
    );
  }

  TaskList _toDomain(TaskListDto taskListDto) {
    return TaskList(
      TaskListId(taskListDto.id),
      title: taskListDto.title,
      tasks: taskListDto.tasks.map(_taskToDomain).toList(),
    );
  }

  TaskDto _taskToDto(Task task) {
    return TaskDto(
      id: task.id.value.toString(),
      title: task.title,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
    );
  }

  Task _taskToDomain(TaskDto taskDto) {
    return Task(
      TaskId.fromString(taskDto.id),
      title: taskDto.title,
      createdAt: taskDto.createdAt,
      completedAt: taskDto.completedAt,
    );
  }
}
