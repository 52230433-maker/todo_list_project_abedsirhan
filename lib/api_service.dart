import 'dart:convert';
import 'package:http/http.dart' as http;
import 'task_model.dart';
import 'linkapi.dart';

class ApiService {
  static Future<List<Task>> getTasks() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<void> addTask(Task task) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    print(res.body);
  }

  static Future<void> updateTask(Task task) async {
    await http.put(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
  }

  static Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('$baseUrl?id=$id'));
  }
}