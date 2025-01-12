import 'package:get/get.dart';
import 'package:task_manager_app/model/task_model.dart';
import 'package:hive/hive.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  var completedTasksCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  void loadTasks() {
    final box = Hive.box<Task>('tasks');
    tasks.assignAll(box.values.toList().cast<Task>());
    updateCompletedTasksCount();
  }

  void addTask(Task task) {
    tasks.add(task);
    Hive.box<Task>('tasks').add(task);
    updateCompletedTasksCount();
  }

  void deleteTask(int index) {
    tasks.removeAt(index);
    Hive.box<Task>('tasks').deleteAt(index);
    updateCompletedTasksCount();
  }

  void markTaskAsCompleted(int index) {
    Task task = tasks[index];
    task.isCompleted = true; // Mark the task as completed
    tasks.removeAt(index); // Remove from current position
    tasks.add(task); // Add to the end of the list
    Hive.box<Task>('tasks').putAt(index, task); // Update the task in Hive
    updateCompletedTasksCount();
  }

  void updateCompletedTasksCount() {
    completedTasksCount.value = tasks.where((task) => task.isCompleted).length;
  }

  List<Task> get filteredTasks {
    return tasks.where((task) => !task.isCompleted).toList();
  }

  Map<String, List<Task>> get groupedTasks {
    return {
      for (var category in tasks.map((task) => task.category).toSet())
        category: tasks.where((task) => task.category == category).toList(),
    };
  }
}
