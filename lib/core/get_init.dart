import 'package:get/get.dart';
import 'package:task_manager_app/controller/task_controller.dart';
import 'package:task_manager_app/controller/theme_controller.dart';

Future <void> getInit() async {
  Get.put(TaskController());
  Get.put(ThemeController());
}