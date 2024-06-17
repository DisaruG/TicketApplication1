import 'package:flutter/material.dart';

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({super.key});

  @override
  TaskCreationScreenState createState() => TaskCreationScreenState();
}

class TaskCreationScreenState extends State<TaskCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Low'; // Default priority
  String _status = 'Not Started'; // Default status
  String? _assignee; // To hold the selected assignee

  // Dummy list of employees (for now)
  List<String> _employees = ['John Doe', 'Jane Smith', 'Alice Johnson', 'Bob Lee'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text('Due Date: ${_dueDate == null ? "Select Date" : _dueDate.toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                onTap: _pickDueDate,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Priority'),
                value: _priority,
                items: ['Low', 'Medium', 'High']
                    .map((priority) => DropdownMenuItem(
                  child: Text(priority),
                  value: priority,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: ['Not Started', 'In Progress', 'Completed']
                    .map((status) => DropdownMenuItem(
                  child: Text(status),
                  value: status,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Assign To'),
                value: _assignee,
                items: _employees
                    .map((employee) => DropdownMenuItem(
                  child: Text(employee),
                  value: employee,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _assignee = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement task creation functionality
                  _createTask();
                },
                child: const Text('Create Task'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(10), // All padding round the button content
                  textStyle: const TextStyle(fontSize: 16),// Adjust the font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to pick a due date
  Future<void> _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  // Placeholder function for task creation
  void _createTask() {
    // Capture task details and handle task creation
    var newTask = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'dueDate': _dueDate,
      'priority': _priority,
      'status': _status,
      'assignee': _assignee,
    };
    print(newTask); // For now, just print the task details
    Navigator.pop(context);
  }
}
