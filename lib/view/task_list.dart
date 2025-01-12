// lib/view/task_list_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import '../controller/task_controller.dart';
import '../model/task_model.dart';
import '../controller/theme_controller.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          GetBuilder<ThemeController>(
            builder: (themeController) {
              return IconButton(
                icon: Icon(
                  themeController.isDarkMode
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                ),
                onPressed: () {
                  themeController.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final groupedTasks = taskController.groupedTasks;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: groupedTasks.entries.map((entry) {
            String category = entry.key;
            List<Task> tasks = entry.value;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ExpansionTile(
                title: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: tasks.map((task) {
                  return Dismissible(
                    key: Key('${task.title}-${task.hashCode}'),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      final index = tasks.indexOf(task);
                      if (direction == DismissDirection.startToEnd) {
                        // Mark as completed
                        taskController.toggleTaskCompletion(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${task.title} marked as completed"),
                          ),
                        );
                      } else {
                        // Delete task
                        taskController.deleteTask(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${task.title} deleted"),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                taskController.addTask(task);
                              },
                            ),
                          ),
                        );
                      }
                    },
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: task.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : CircularProgressIndicator(
                              value: task.loadingProgress),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddTaskScreen());
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
