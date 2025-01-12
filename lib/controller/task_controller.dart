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

  void toggleTaskCompletion(int index) {
    Task task = tasks[index];
    if (!task.isCompleted) {
      // Simulate loading progress
      task.loadingProgress = 0.0;
      tasks[index] = task; // Update the task in the list

      // Simulate a loading process
      Future.delayed(Duration(seconds: 2), () {
        task.isCompleted = true;
        task.loadingProgress = 1.0; // Set loading progress to 100%
        tasks[index] = task; // Update the task in the list
        updateCompletedTasksCount();
      });
    }
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
