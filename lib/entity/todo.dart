import 'package:floor/floor.dart';

@Entity(tableName: 'todos')
class Todo {
  
  @PrimaryKey(autoGenerate: true) 
  final int? id;

  final String name;

  Todo(this.id, this.name);
 
 }