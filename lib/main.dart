import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/todo_database.dart';
import 'package:todo_app/entity/todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO app',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Simple TODO app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseApp database;
  late String textForTodo;

  @override
  void initState() {
    super.initState();
    //Initialize Floor database
    $FloorDatabaseApp
        .databaseBuilder('todo_database.db')
        .build()
        .then((value) async {
      database = value;
      List<Todo> list = await database.todoDAO.findAllTodos();

      if (list.isEmpty) {
        await addTodos(database);
      }

      setState(() {});
    });
  }

  Future<List<int>> addTodos(DatabaseApp db) async {
    //Dummy data
    Todo todo1 = Todo(null, "Do homework for today");
    Todo todo2 = Todo(null, "Buy groceries");
    Todo todo3 = Todo(null, "Make food");
    Todo todo4 = Todo(null, "Do exercise for mobile");

    return await db.todoDAO.insertTodos([todo1, todo2, todo3, todo4]);
  }

  Future<List<Todo>> getAllTodos() async {
    return await database.todoDAO.findAllTodos();
  }

  Future<void> addTodo(Todo todo) async {
    await database.todoDAO.insertTodo(todo);
  }

  TextEditingController todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: const Text('About the TODO app'),
                          content: const Text(
                              'It is a simple TODO app. \nUse the + button to add a TODO\nSwipe left to delete a TODO\nDeveloped by: Nicolaj Aalykke Hansen (nicol20)'),
                          actions: <Widget>[
                            TextButton(
                                onPressed: (() {
                                  Navigator.of(context).pop();
                                }),
                                child: const Text("Close"))
                          ],
                        ));
              },
              icon: const Icon(Icons.help))
        ],
      ),
      body: FutureBuilder(
        future: getAllTodos(),
        builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible( //Dismissible allows for easy deletion again by swiping
                  direction: DismissDirection.endToStart,
                  background: Container( //When swiping starts
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: const Icon(Icons.delete_forever),
                  ),
                  key: ValueKey<int>(snapshot.data![index].id!),
                  onDismissed: (DismissDirection direction) async { //When swiped
                    await database.todoDAO.delete(snapshot.data![index].id!);
                    setState(() {
                      snapshot.data!.remove(snapshot.data![index]);
                    });
                  },
                  child: Card(
                      child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    title: Text(snapshot.data![index].name),
                  )),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog( //Create dialog
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Add TODO'),
              content: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter your TODO',
                ),
                controller: todoController,
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: (() {
                      todoController.clear(); //Clear the text
                      Navigator.of(context).pop(); //Remove the dialog
                    }),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: (() {
                      if (todoController.text.isEmpty) {
                        return; //Ensure no empty TODOs are added
                      }
                      setState(() {
                        addTodo(Todo(
                            null,
                            todoController
                                .text)); //id is null as ID will be given automatically
                      });
                      todoController.clear(); //Clear the text
                      Navigator.of(context).pop(); //Remove the dialog
                    }),
                    child: const Text("Save")),
              ],
            ),
          );
        },
        tooltip: 'Add TODO',
        child: const Icon(Icons.add),
      ),
    );
  }
}
