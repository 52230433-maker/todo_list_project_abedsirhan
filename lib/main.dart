import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fancy Todo App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const TodoHomePage(),
    );
  }
}

class Todo {
  final int id;
  final String title;
  final String description;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isDone: json['is_done'].toString() == '1',
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final String backendUrl = 'http://localhost/backend/tasks.php';
  List<Todo> tasks = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      var response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body) as List;
        setState(() {
          tasks = jsonData.map((t) => Todo.fromJson(t)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  Future<void> addTask(String title, String description) async {
    try {
      var response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'description': description, 'is_done': 0}),
      );
      var data = jsonDecode(response.body);
      if (data['success'] == true) {
        fetchTasks();
        titleController.clear();
        descriptionController.clear();
      }
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> toggleDone(Todo task) async {
    try {
      var response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'is_done': task.isDone ? 0 : 1
        }),
      );
      fetchTasks();
    } catch (e) {
      debugPrint('Error toggling task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'delete_id': id}),
      );
      fetchTasks();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Color cardColor(bool isDone) => isDone ? Colors.green.shade100 : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Fancy Todo App'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      addTask(titleController.text, descriptionController.text);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                var task = tasks[index];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => toggleDone(task),
                    child: Card(
                      elevation: 3,
                      color: cardColor(task.isDone),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.isDone,
                              onChanged: (_) => toggleDone(task),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(task.title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: task.isDone
                                              ? TextDecoration.lineThrough
                                              : null)),
                                  Text(task.description,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          decoration: task.isDone
                                              ? TextDecoration.lineThrough
                                              : null)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteTask(task.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}