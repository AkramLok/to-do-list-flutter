import 'dart:convert';
import 'package:http/http.dart' as http;

class Task {
  final int id;
  final String title;
  final String description;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'] == 1,
    );
  }
}

Future<List<Task>> fetchTasks() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/tasks'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((task) => Task.fromJson(task)).toList();
  } else {
    throw Exception('Failed to load tasks');
  }
}

Future<Task> createTask(Task task) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/api/tasks'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'title': task.title,
      'description': task.description,
    }),
  );

  if (response.statusCode == 201) {
    return Task.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create task');
  }
}

Future<Task> updateTask(int id, Task task) async {
  final response = await http.put(
    Uri.parse('http://10.0.2.2:8000/api/tasks/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'title': task.title,
      'description': task.description,
    }),
  );

  if (response.statusCode == 200) {
    return Task.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update task');
  }
}


Future<void> deleteTask(int id) async {
  final response = await http.delete(
    Uri.parse('http://10.0.2.2:8000/api/tasks/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete task');
  }
}

Future<Task> toggleTaskCompletion(int id) async {
  final response = await http.patch(
    Uri.parse('http://10.0.2.2:8000/api/tasks/$id/toggle-complete'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return Task.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to toggle task completion');
  }
}

