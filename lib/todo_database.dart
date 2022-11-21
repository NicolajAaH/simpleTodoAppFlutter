import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:todo_app/dao/todoDAO.dart';
import 'package:todo_app/entity/todo.dart';

part 'todo_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Todo])
abstract class DatabaseApp extends FloorDatabase {
  TodoDAO get todoDAO;
}