import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:todo_app/vm.dart';
import 'package:todo_app/task.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: ChangeNotifierProvider(
          create: (context) => MainViewModel(),
          child: HomePage(),
        )
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MainViewModel vm = Provider.of<MainViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: ListView.builder(
          itemBuilder: (BuildContext context, int index) => _listItem(context, index),
          itemCount: vm.tasks.length,
        ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => _dialog(new Task(), context, vm.addTask),
            );
          }
      ),
    );
  }

  Dismissible _listItem(BuildContext context, int index) {
    MainViewModel vm = Provider.of<MainViewModel>(context);
    Task task = vm.tasks[index];
    TextStyle style = TextStyle(
        color:Colors.black,
        fontSize: 18.0,
        decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none
    );

    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => {
        vm.removeTask(task)
      },
      background: Container(color: Colors.red),
      child: Container(
        decoration: new BoxDecoration(
            border: new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
        ),
        child: ListTile(
          title: Text(task.title, style: style,),
          onTap: () => vm.turnTask(task),
          onLongPress: ()  {
            showDialog(
              context: context,
              builder: (context) => _dialog(task, context, vm.saveTask),
            );
          },
        ),
      ),
    );
  }

  Widget _dialog(Task task, BuildContext context, handler) {
    final _formKey = GlobalKey<FormState>();
    String _input = task.title;

    return AlertDialog(
      title: Text("Edit"),
      content:  Form(
        key: _formKey,
        child: Container(
          child: TextFormField(
            decoration: InputDecoration(hintText: 'title'),
            validator: (value) => value.isEmpty ?'Please enter some text': null,
            initialValue: _input,
            onChanged: (e) => _input = e,
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Save"),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              task.title = _input;
              handler(task);
              Navigator.of(context).pop();
            }
          },
        ),
        FlatButton(
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

