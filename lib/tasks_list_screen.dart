import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_creation_screen.dart';
import 'task_details_screen.dart';

class TasksListScreen extends StatefulWidget {
  final String? searchQuery;

  const TasksListScreen({super.key, this.searchQuery});

  @override
  _TasksListScreenState createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets') // Ensure collection name is correct
            .orderBy('timestamp', descending: true) // Order by timestamp
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tasks available',
                style: TextStyle(fontSize: 18, color: Color(0xFF333333)), // Charcoal Gray
              ),
            );
          }

          // Filter tasks based on search query
          var tasks = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'subject': data['subject'] ?? 'No Subject',
              'description': data['description'] ?? 'No Description',
              'dueDate': data['dueDate'] ?? 'No Due Date',
              'assignee': data['assignee'] ?? 'Unassigned',
              'priority': data['priority'] ?? 'Low',
              'status': data['status'] ?? 'Not Started',
              'isRead': data['isRead'] ?? false,
            };
          }).toList();

          // Apply search filter
          if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
            tasks = tasks.where((task) =>
                task['assignee'].toLowerCase().contains(widget.searchQuery!.toLowerCase())).toList();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              return Card(
                color: task['isRead'] == true ? const Color(0xFFF4F4F4) : const Color(0xFFE0F7FA), // Soft Gray and Teal
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3.0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['assignee'], // Show assignee's name at the top
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF003366), // Deep Navy Blue
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        task['subject'], // Show task title
                        style: const TextStyle(
                          fontWeight: FontWeight.w500, // Semi-bold title
                          fontSize: 14,
                          color: Color(0xFF333333), // Charcoal Gray
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Due: ${task['dueDate']}', // Show due date
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF333333), // Charcoal Gray
                        ),
                      ),
                    ],
                  ),
                  trailing: _buildStatusChip(task['status']),
                  onTap: () async {
                    // Print task data for debugging
                    print('Navigating to TaskDetailsScreen with task: $task');

                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
                    );

                    _markTaskAsRead(task['id']);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(CupertinoIcons.add, color: Colors.white), // White icon
        backgroundColor: const Color(0xFF003366), // Deep Navy Blue
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

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    switch (status) {
      case 'In Progress':
        backgroundColor = const Color(0xFF003366); // Deep Navy Blue
        break;
      case 'Completed':
        backgroundColor = const Color(0xFF4CAF50); // Green
        break;
      case 'Not Started':
      default:
        backgroundColor = const Color(0xFFCCCCCC); // Light Gray
    }
    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
    );
  }

  void _markTaskAsRead(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').doc(taskId).update({
        'isRead': true,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error marking task as read')),
      );
    }
  }
}
