import 'package:flutter/material.dart';
import 'task_creation_screen.dart';
import 'task_details_screen.dart';

class TasksListScreen extends StatelessWidget {
  const TasksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for task list
    List<Map<String, dynamic>> tasks = [
      {
        'title': 'Task 1',
        'description': 'Task 1 description',
        'dueDate': '2024-12-31',
        'priority': 'High',
        'status': 'Not Started',
        'assignee': 'John Doe'
      },
      {
        'title': 'Task 2',
        'description': 'Task 2 description',
        'dueDate': '2024-11-30',
        'priority': 'Medium',
        'status': 'In Progress',
        'assignee': 'Jane Smith'
      },
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          var task = tasks[index];
          return ListTile(
            title: Text(task['title']),
            subtitle: Text('Due: ${task['dueDate']}, Assigned to: ${task['assignee']}'),
            onTap: () {
              // Navigate to Task Details Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to Task Creation Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskCreationScreen()),
          );
        },
      ),
    );
  }
}
