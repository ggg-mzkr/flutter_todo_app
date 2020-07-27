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
        background: Padding(
            padding: EdgeInsets.all(1.0),
            child: Container(color: Colors.red)
        ),
        child: Padding(
            padding: EdgeInsets.all(1.0),
            child: Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(task.title, style: style,),
                      trailing: IconButton(
                        icon: Icon(task.done? Icons.check_box: Icons.check_box_outline_blank,),
                        onPressed: () => vm.turnTask(task),
                      ),
                      onTap: () => { vm.toggleShow(task) },
                      onLongPress: ()  {
                        showDialog(context: context, builder: (context) => _dialog(task, context, vm.saveTask));
                      },
                    ),
                    Visibility(
                      visible: task.show,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.black, width: 1.0)),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                        padding: EdgeInsets.all(10.0),
                        child: Text(task.content, textAlign: TextAlign.left,),
                      ),
                    )
                  ],
                )
            )
        )
    );
  }

  Widget _dialog(Task task, BuildContext context, handler) {
    final _formKey = GlobalKey<FormState>();
    String _title = task.title;
    String _content = task.content;

    return AlertDialog(
      title: Text("Edit"),
      content:  Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'title'),
                validator: (value) => value.isEmpty ?'Please enter some text': null,
                initialValue: _title,
                onChanged: (e) => _title = e,
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'content'),
                maxLines: 10,
                minLines: 3,
                initialValue: _content,
                onChanged: (e) => _content = e,
              ),
            ],
          )
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Save"),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              task.title = _title;
              task.content = _content;
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

