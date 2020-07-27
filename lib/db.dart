import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'task.dart' as dto;

part 'db.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  BoolColumn get done => boolean()();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: [Tasks])
class TaskRepository extends _$TaskRepository {
  TaskRepository() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  Future<List<dto.Task>> get all => select(tasks)
      .map((Task t) => new dto.Task(id: t.id, title: t.title, content: t.content, done: t.done))
      .get()
  ;

  Future<void> remove(dto.Task task) {
    return (delete(tasks)..where((it) => it.id.equals(task.id))).go();
  }

  Future<void> upsert(dto.Task task) {
    return into(tasks).insertOnConflictUpdate(Task(
        id: task.id,
        title: task.title,
        content: task.content,
        done: task.done
    ));
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(tasks, tasks.content);
        }
      }
  );
}