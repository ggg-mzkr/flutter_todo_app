import 'package:flutter/cupertino.dart';

import 'Task.dart';

class MainViewModel with ChangeNotifier {

  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    saveTask(task);
  }

  void turnTask(Task task) {
    task.done = !task.done;
    notifyListeners();
  }

  void saveTask(Task task) {
    notifyListeners();
  }
}