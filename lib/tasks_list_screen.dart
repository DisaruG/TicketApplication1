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
  String? _selectedTaskId; // State variable to track selected task ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tasks available',
                style: TextStyle(fontSize: 18, color: Color(0xFF333333)),
              ),
            );
          }

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

          if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
            tasks = tasks.where((task) =>
                task['assignee'].toLowerCase().contains(widget.searchQuery!.toLowerCase())).toList();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    _selectedTaskId = task['id']; // Set selected task ID on long press
                  });
                },
                child: Card(
                  color: task['isRead'] == true ? const Color(0xFFF4F4F4) : const Color(0xFFE0F7FA),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    leading: _getPriorityIcon(task['priority']),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['assignee'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          task['subject'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Due: ${task['dueDate']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    trailing: _selectedTaskId == task['id']
                        ? IconButton(
                      icon: const Icon(CupertinoIcons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteTask(task['id']);
                      },
                    )
                        : _buildStatusChip(task['status']),
                    onTap: () async {
                      if (_selectedTaskId == task['id']) {
                        // If task is selected, reset selection
                        setState(() {
                          _selectedTaskId = null;
                        });
                      } else {
                        // Print task data for debugging
                        print('Navigating to TaskDetailsScreen with task: $task');

                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
                        );

                        _markTaskAsRead(task['id']);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF003366),
        onPressed: () async {
          bool? isTaskCreated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TicketCreationScreen()),
          );
          if (isTaskCreated == true) {
            setState(() {});
          }
        },
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    switch (status) {
      case 'In Progress':
        backgroundColor = const Color(0xFF003366);
        break;
      case 'Completed':
        backgroundColor = const Color(0xFF4CAF50);
        break;
      case 'Not Started':
      default:
        backgroundColor = const Color(0xFFCCCCCC);
    }
    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget _getPriorityIcon(String priority) {
    IconData iconData;
    switch (priority) {
      case 'High':
        iconData = CupertinoIcons.exclamationmark_triangle;
        break;
      case 'Medium':
        iconData = CupertinoIcons.exclamationmark_circle;
        break;
      case 'Low':
      default:
        iconData = CupertinoIcons.circle;
    }
    return Icon(
      iconData,
      color: _getPriorityColor(priority),
      size: 24.0,
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
      default:
        return Colors.green;
    }
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

  void _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
      setState(() {
        _selectedTaskId = null; // Reset selection after deletion
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting task')),
      );
    }
  }
}
