import 'package:flutter/cupertino.dart';

import 'Task.dart';
import 'db.dart' as db;

class MainViewModel with ChangeNotifier {

  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  db.TaskRepository _repository = new db.TaskRepository();

  MainViewModel() {
   _repository.all.then((List<Task> tasks) {
     _tasks = tasks;
     notifyListeners();
   });
  }

  void addTask(Task task) {
    _tasks.add(task);
    saveTask(task);
  }

  void turnTask(Task task) {
    task.done = !task.done;
    saveTask(task);
  }

  void saveTask(Task task) {
    _repository.upsert(task).then((_) => notifyListeners());
  }
}