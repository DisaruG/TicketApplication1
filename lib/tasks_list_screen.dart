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
        stream: widget.searchQuery != null && widget.searchQuery!.isNotEmpty
            ? FirebaseFirestore.instance
            .collection('tickets')
            .where('assignee', isEqualTo: widget.searchQuery)
            .orderBy('timestamp', descending: true)
            .snapshots()
            : FirebaseFirestore.instance
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

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var task = doc.data() as Map<String, dynamic>;
              task['id'] = doc.id; // Add the document ID to the task map

              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    _selectedTaskId = task['id'] ?? ''; // Use empty string if id is null
                  });
                },
                child: Card(
                  color: (task['isRead'] == true) ? const Color(0xFFF4F4F4) : const Color(0xFFE0F7FA),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    leading: _getPriorityIcon(task['priority'] ?? 'Low'), // Provide default value
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['assignee'] ?? 'Unknown Assignee', // Provide default value
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          task['subject'] ?? 'No Subject', // Provide default value
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Due: ${task['dueDate'] ?? 'No Due Date'}', // Provide default value
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF008080), // Teal
                          ),
                        ),
                      ],
                    ),
                    trailing: _selectedTaskId == task['id']
                        ? IconButton(
                      icon: const Icon(CupertinoIcons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteTask(task['id'] ?? '');
                      },
                    )
                        : _buildStatusIcon(task['status'] ?? 'Not Started'), // Provide default value
                    onTap: () async {
                      if (_selectedTaskId == task['id']) {
                        setState(() {
                          _selectedTaskId = null;
                        });
                      } else {
                        print('Navigating to TaskDetailsScreen with task: $task');
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
                        );
                        _markTaskAsRead(task['id'] ?? '');
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        icon: const Icon(CupertinoIcons.add, color: Colors.white),
        label: const Text('New Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    Color backgroundColor;
    IconData statusIcon;
    switch (status) {
      case 'In Progress':
        backgroundColor = const Color(0xFF003366);
        statusIcon = CupertinoIcons.arrow_2_circlepath;
        break;
      case 'Completed':
        backgroundColor = const Color(0xFF4CAF50);
        statusIcon = CupertinoIcons.check_mark;
        break;
      case 'Not Started':
      default:
        backgroundColor = const Color(0xFFCCCCCC);
        statusIcon = CupertinoIcons.time;
    }
    return Chip(
      avatar: Icon(statusIcon, color: Colors.white, size: 18.0), // Adjusted icon size
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
