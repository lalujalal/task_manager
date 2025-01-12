// lib/view/task_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import the animation package
import '../controller/task_controller.dart';
import '../model/task_model.dart';
import '../controller/theme_controller.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
                  themeController.toggleTheme(); // Toggle theme on button press
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Tasks',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    searchQuery = '';
                  },
                ),
              ),
              onChanged: (value) {
                searchQuery = value.toLowerCase();
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final groupedTasks = taskController.groupedTasks;

              // Filter tasks based on search query
              final filteredTasks = groupedTasks.entries
                  .map((entry) {
                    String category = entry.key;
                    List<Task> tasks = entry.value
                        .where((task) =>
                            task.title.toLowerCase().contains(searchQuery))
                        .toList();

                    return MapEntry(category, tasks);
                  })
                  .where((entry) => entry.value.isNotEmpty)
                  .toList();

              // Check if there are any tasks matching the search query
              if (searchQuery.isNotEmpty && filteredTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                              size: 100, color: Colors.grey)
                          .animate()
                          .fadeIn()
                          .scale()
                          .then()
                          .shake(),
                      const SizedBox(height: 16.0),
                      const Text(
                        'No tasks found matching your search.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().moveY().then().moveY(),
                    ],
                  ),
                );
              }

              // Check if the task list is empty
              if (filteredTasks.isEmpty && groupedTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list, size: 100, color: Colors.grey)
                          .animate()
                          .fadeIn()
                          .scale()
                          .then()
                          .shake(),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Your list is empty.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().moveY().then().moveY(),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: filteredTasks.map((entry) {
                  String category = entry.key;
                  List<Task> tasks = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ExpansionTile(
                      title: Text(
                        category,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20), // Styled heading
                      ),
                      children: tasks.map((task) {
                        return Dismissible(
                          key: Key(
                              '${task.title}-${task.hashCode}'), // Unique key
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            final index = tasks.indexOf(task);
                            if (direction == DismissDirection.startToEnd) {
                              // Mark as completed
                              taskController.markTaskAsCompleted(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("${task.title} marked as completed"),
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
                                      taskController
                                          .addTask(task); // Undo deletion
                                    },
                                  ),
                                ),
                              );
                            }

                            // Check if the task list is empty and close the dropdown if it is
                            if (tasks.isEmpty) {
                              Navigator.of(context).pop(); // Close the dropdown
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
                            title: Text(task.title)
                                .animate()
                                .fadeIn(), // Animation for task title
                            subtitle: Text(
                              task.description,
                              maxLines: 1,
                              overflow: TextOverflow
                                  .ellipsis, // Truncate after one line
                            ),
                            trailing: task.isCompleted
                                ? const Icon(Icons.check_circle,
                                    color: Colors
                                        .green) // Show tick mark if completed
                                : const Icon(Icons.hourglass_empty,
                                    color: Colors
                                        .grey), // Static symbol for incomplete tasks
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Add a new task',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ).animate().fadeIn().moveY().then().moveY(), // Animated caption
          const SizedBox(height: 8.0),
          FloatingActionButton(
            onPressed: () {
              Get.to(() => AddTaskScreen()); // Navigate to AddTaskScreen
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Task',
          ),
        ],
      ),
    );
  }
}
