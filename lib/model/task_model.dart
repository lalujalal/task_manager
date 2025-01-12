   // lib/task_model.dart
   import 'package:hive/hive.dart';

   part 'task_model.g.dart'; // This line is crucial for the build runner to generate the adapter

   @HiveType(typeId: 0)
   class Task {
     @HiveField(0)
     final String title;

     @HiveField(1)
     final String description;

     @HiveField(2)
     final String category;

     @HiveField(3)
     bool isCompleted;

     Task({
       required this.title,
       required this.description,
       required this.category,
       this.isCompleted = false,
     });
   }