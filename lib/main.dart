import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager_app/controller/theme_controller.dart';
import 'package:task_manager_app/core/get_init.dart';
import 'package:task_manager_app/model/task_model.dart';
import 'package:task_manager_app/view/task_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  if (!Hive.isBoxOpen('tasks')) {
    await Hive.openBox<Task>('tasks');
  }
  await getInit();

  // Initialize ThemeController
  Get.put(ThemeController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Task Manager App',
          theme: themeController
              .themeData, // Use Get.find to get the ThemeController
          home: TaskListScreen(),
        );
      },
    );
  }
}
