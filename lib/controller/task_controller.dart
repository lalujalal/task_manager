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
    tasks[index].isCompleted = !tasks[index].isCompleted;
    Hive.box<Task>('tasks').putAt(index, tasks[index]);
    updateCompletedTasksCount();
  }

  void updateCompletedTasksCount() {
    completedTasksCount.value = tasks.where((task) => task.isCompleted).length;
  }

  List<Task> get filteredTasks {
    return tasks.where((task) => !task.isCompleted).toList();
  }
}