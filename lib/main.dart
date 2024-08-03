import 'package:flutter/material.dart';
import 'task.dart';
import 'task_form.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task List',
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = fetchTasks();
  }

  void _refreshTasks() {
    setState(() {
      futureTasks = fetchTasks();
    });
  }

  void _navigateToTaskForm([Task? task]) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskForm(task: task),
      ),
    );
    if (result == true) {
      _refreshTasks();
    }
  }

  void _deleteTask(int id) async {
    await deleteTask(id);
    _refreshTasks();
  }

  void _toggleTaskCompletion(int id) async {
    await toggleTaskCompletion(id);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToTaskForm(),
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No tasks found"));
          }

          List<Task>? tasks = snapshot.data;
          List<Task> completedTasks = tasks!.where((task) => task.completed).toList();
          List<Task> incompletedTasks = tasks.where((task) => !task.completed).toList();

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TaskSection(
                  title: 'Incompleted Tasks',
                  tasks: incompletedTasks,
                  onEdit: _navigateToTaskForm,
                  onDelete: _deleteTask,
                  onToggleComplete: _toggleTaskCompletion,
                ),
                TaskSection(
                  title: 'Completed Tasks',
                  tasks: completedTasks,
                  onEdit: _navigateToTaskForm,
                  onDelete: _deleteTask,
                  onToggleComplete: _toggleTaskCompletion,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TaskSection extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final void Function(Task) onEdit;
  final void Function(int) onDelete;
  final void Function(int) onToggleComplete;

  TaskSection({
    required this.title,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(tasks[index].title),
              subtitle: Text(tasks[index].description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => onEdit(tasks[index]),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => onDelete(tasks[index].id),
                  ),
                  IconButton(
                    icon: Icon(tasks[index].completed ? Icons.check_box : Icons.check_box_outline_blank),
                    onPressed: () => onToggleComplete(tasks[index].id),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
