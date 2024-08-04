import 'package:flutter/material.dart';
import 'task.dart';
import 'task_form.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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

  Future<void> _confirmDeleteTask(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this task?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteTask(id);
      _refreshTasks();
    }
  }

  void _toggleTaskCompletion(int id) async {
    await toggleTaskCompletion(id);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Icon(
              Icons.list, // Choose the icon you want here
              color: Colors.white,
            ),
            SizedBox(width: 8.0), // Space between the icon and text
            Text(
              'To-Do List',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Colors.white,
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
            return Center(child: Text("No tasks found", style: TextStyle(color: Colors.grey)));
          }

          List<Task>? tasks = snapshot.data;
          List<Task> completedTasks = tasks!.where((task) => task.completed).toList();
          List<Task> incompletedTasks = tasks.where((task) => !task.completed).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  TaskSection(
                    title: 'Incomplete Tasks',
                    tasks: incompletedTasks,
                    onEdit: _navigateToTaskForm,
                    onDelete: _confirmDeleteTask,
                    onToggleComplete: _toggleTaskCompletion,
                  ),
                  SizedBox(height: 16.0),
                  TaskSection(
                    title: 'Completed Tasks',
                    tasks: completedTasks,
                    onEdit: _navigateToTaskForm,
                    onDelete: _confirmDeleteTask,
                    onToggleComplete: _toggleTaskCompletion,
                  ),
                ],
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  title == 'Incomplete Tasks'
                      ? Icons.hourglass_empty // Icon for incomplete tasks
                      : Icons.check_circle_outline, // Icon for completed tasks
                  color: Colors.lightBlue, // Light blue color for icons
                ),
                SizedBox(width: 8.0), // Space between icon and text
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ],
            ),
          ),
          tasks.isEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                'No $title found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    leading: Icon(
                      tasks[index].completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: tasks[index].completed ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      tasks[index].title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: tasks[index].completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(tasks[index].description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.lightBlue),
                          onPressed: () => onEdit(tasks[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDelete(tasks[index].id),
                        ),
                        IconButton(
                          icon: Icon(
                            tasks[index].completed
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.lightBlue,
                          ),
                          onPressed: () => onToggleComplete(tasks[index].id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

