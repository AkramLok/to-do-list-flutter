import 'package:flutter/material.dart';
import 'task.dart';

class TaskForm extends StatefulWidget {
  final Task? task;

  TaskForm({this.task});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _completed = widget.task?.completed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      Task task = Task(
        id: widget.task?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text,
        completed: _completed,
      );

      Future<void> future;
      if (widget.task == null) {
        future = createTask(task);
      } else {
        future = updateTask(widget.task!.id, task);
      }

      future.then((_) {
        Navigator.pop(context, true);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    }
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All'),
          content: Text('Are you sure you want to clear all fields?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _titleController.clear();
                  _descriptionController.clear();
                  _completed = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Icon(
              Icons.edit, // Replace this with the icon you want
              color: Colors.white,
            ),
            SizedBox(width: 8.0), // Space between the icon and text
            Text(
              widget.task == null ? 'Create Task' : 'Edit Task',
              style: TextStyle(
                color: Colors.white, // Color of the text
                fontSize: 20, // Font size of the text
              ),
            ),
          ],
        ),
        backgroundColor: Colors.lightBlue, // Background color of the AppBar
        iconTheme: IconThemeData(
          color: Colors.white, // Color of the back arrow
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter task title',
                          icon: Icon(Icons.title, color: Colors.blueGrey),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter task description',
                          icon: Icon(Icons.description, color: Colors.blueGrey),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    style: ButtonStyle(
                      // Background color (not typically used for OutlinedButton, but can be set for its overlay effect)
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0XFFFEF7FF)),

                      // Border color
                      side: MaterialStateProperty.all<BorderSide>(BorderSide(color: Colors.lightBlue, width: 2)),

                      // Text color
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue),

                      // Padding
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 12.0)),

                      // Shape (optional, if you want to modify the button's shape)
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),

                      // Text style
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                    ),
                    child: Text('Clear All'),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saveTask,
                    style: ButtonStyle(
                      // Border color and width
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(color: Colors.blue, width: 2),
                      ),

                      // Background color (important for hover/pressed states, but won't be seen for OutlinedButton with default transparent background)
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue),

                      // Text color
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),

                      // Padding
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 12.0)),

                      // Shape (optional, if you want to modify the button's shape)
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),

                      // Text style (optional, set directly here or via child)
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
