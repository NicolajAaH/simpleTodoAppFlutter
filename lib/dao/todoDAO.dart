import 'package:floor/floor.dart';
import 'package:todo_app/entity/todo.dart';

@dao
abstract class TodoDAO {
  @Query('SELECT * FROM todos')
  Future<List<Todo>> findAllTodos();

  @insert
  Future<void> insertTodo(Todo todo);

  @insert
  Future<List<int>> insertTodos(List<Todo> todos);

  @Query('DELETE FROM todos WHERE id = :id')
  Future<void> delete(int id);
}
