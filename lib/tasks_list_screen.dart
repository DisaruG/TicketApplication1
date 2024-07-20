import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_creation_screen.dart';
import 'task_details_screen.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  _TasksListScreenState createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tasks available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          var tasks = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3.0,
                child: ListTile(
                  leading: _buildPriorityIcon(task['priority']),
                  title: Text(task['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4.0),
                      Text('Due: ${task['dueDate']}'),
                      Text('Assigned to: ${task['assignee']}'),
                    ],
                  ),
                  trailing: _buildStatusChip(task['status']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          bool? isTaskCreated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TicketCreationScreen()),
          );
          if (isTaskCreated == true) {
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildPriorityIcon(String priority) {
    switch (priority) {
      case 'High':
        return const Icon(Icons.priority_high, color: Colors.red);
      case 'Medium':
        return const Icon(Icons.priority_high, color: Colors.orange);
      case 'Low':
      default:
        return const Icon(Icons.priority_high, color: Colors.green);
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    switch (status) {
      case 'In Progress':
        backgroundColor = Colors.blue;
        break;
      case 'Completed':
        backgroundColor = Colors.green;
        break;
      case 'Not Started':
      default:
        backgroundColor = Colors.grey;
    }
    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
    );
  }
}



