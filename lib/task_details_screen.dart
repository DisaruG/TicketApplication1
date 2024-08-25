import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Debug print to ensure data is being passed correctly
    print('TaskDetailsScreen received task: $task');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          task['subject'] ?? 'No Subject',
          style: const TextStyle(
            color: Color(0xFF333333), // Charcoal Gray
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF333333)), // Charcoal Gray
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFFF4F4F4), // Soft Gray
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Title:', task['subject'] ?? 'No Title'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Description:', task['description'] ?? 'No Description'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Due Date:', task['dueDate'] ?? 'No Due Date'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Priority:', task['priority'] ?? 'Low'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Status:', task['status'] ?? 'Not Started'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Assigned To:', task['assignee'] ?? 'No Assignee'),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _markAsComplete(context, task['id']);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF003366), // Deep Navy Blue
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 6.0,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Mark as Complete',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _markAsInProgress(context, task['id']);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF008080), // Teal
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 6.0,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Start Working',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF333333), // Charcoal Gray
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333), // Charcoal Gray
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markAsComplete(BuildContext context, String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').doc(taskId).update({
        'status': 'Completed',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error marking task as complete')),
      );
    }
  }

  Future<void> _markAsInProgress(BuildContext context, String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').doc(taskId).update({
        'status': 'In Progress',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error marking task as in progress')),
      );
    }
  }
}
