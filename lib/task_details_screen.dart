import 'package:flutter/material.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${task['title']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Description: ${task['description']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Due Date: ${task['dueDate'] ?? 'No due date set'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Priority: ${task['priority']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Status: ${task['status']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Assigned To: ${task['assignee'] ?? 'No assignee'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement task completion functionality
                Navigator.pop(context);
              },
              child: const Text('Mark as Complete'),
            ),
          ],
        ),
      ),
    );
  }
}