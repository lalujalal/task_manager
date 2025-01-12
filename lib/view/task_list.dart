// lib/view/task_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../controller/task_controller.dart';
import '../model/task_model.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  final TaskController taskController = Get.put(TaskController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => AddTaskScreen());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Tasks',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                taskController.loadTasks(); // Reload tasks to filter
              },
            ),
          ),
          Obx(() {
            final filteredTasks = taskController.tasks
                .where((task) => task.title.contains(searchController.text))
                .toList();

            double completedTasks = filteredTasks
                .where((task) => task.isCompleted)
                .length
                .toDouble();
            double totalTasks = filteredTasks.length.toDouble();
            double progress = totalTasks > 0 ? (completedTasks / totalTasks) : 0;

            return Column(
              children: [
                LinearProgressIndicator(value: progress),
                Text('${(progress * 100).toStringAsFixed(0)}% of tasks completed'),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Dismissible(
                        key: Key(task.title),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            taskController.deleteTask(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Task deleted"),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    // Undo delete logic
                                  },
                                ),
                              ),
                            );
                          } else {
                            taskController.toggleTaskCompletion(index);
                          }
                        },
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(task.description),
                          trailing: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) {
                              taskController.toggleTaskCompletion(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}