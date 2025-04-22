import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/task_list/domain/task_list_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app2/task_list/infrastructure/task_list_dtos.dart';


final taskListRepositoryProvider = Provider<TaskListRepository>((ref) {
  // This should be overridden in main.dart with the actual implementation
  throw UnimplementedError();
});

final taskListBoxProvider = FutureProvider<Box<TaskListDto>>((ref) async {
  return Hive.openBox<TaskListDto>('taskLists');
});