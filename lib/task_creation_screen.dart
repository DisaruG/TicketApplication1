import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:logging/logging.dart';

class TicketCreationScreen extends StatefulWidget {
  const TicketCreationScreen({super.key});

  @override
  TicketCreationScreenState createState() => TicketCreationScreenState();
}

class TicketCreationScreenState extends State<TicketCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Low';
  String _category = 'General';
  String? _assignee;
  String? _organization;
  String? _contactEmail;
  PlatformFile? _attachedFile;
  bool _isLoading = false;
  bool _isAttachingFile = false;
  List<String> _employees = [];
  List<String> organizations = ['Regional Development Bank'];

  final List<String> _contacts = [];
  final List<String> _categories = [
    'General',
    'Bug',
    'Feature',
    'Support',
    'Inquiry'
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  final Logger _logger = Logger('TicketCreationScreen');

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserEmail().then((_) => _fetchUsers());
    _organization = organizations.first;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _contactEmail = user.email;
        if (_contactEmail != null && !_contacts.contains(_contactEmail)) {
          _contacts.add(_contactEmail!);
        }
      });
    }
  }

  Future<void> _fetchUsers() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

      List<String> users = snapshot.docs.map((doc) {
        return (doc['displayName'] ?? 'No Name') as String;
      }).toList();

      if (user != null) {
        users.removeWhere((userName) => userName == user.displayName);
      }

      setState(() {
        _employees = users;
      });
    } catch (e) {
      _logger.severe("Error fetching users", e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Create New Ticket',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Organization',
                  child: _buildDropdownField(
                    value: _organization,
                    items: organizations,
                    onChanged: (value) => setState(() => _organization = value),
                  ),
                ),
                _buildSection(
                  title: 'Contact Email',
                  child: _buildDropdownField(
                    value: _contactEmail,
                    items: _contacts,
                    onChanged: (value) => setState(() => _contactEmail = value),
                  ),
                ),
                _buildSection(
                  title: 'Subject',
                  child: _buildTextField(
                    controller: _subjectController,
                    label: 'Subject',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                  ),
                ),
                _buildSection(
                  title: 'Description',
                  child: _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ),
                _buildSection(
                  title: 'Due Date',
                  child: ListTile(
                    title: Text('Due Date: ${_dueDate == null ? "Select Date" : _dueDate.toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                    onTap: _pickDueDate,
                  ),
                ),
                _buildSection(
                  title: 'Assign To',
                  child: _buildSearchableDropdownField(
                    value: _assignee,
                    items: _employees,
                    onChanged: (value) => setState(() => _assignee = value),
                  ),
                ),
                _buildSection(
                  title: 'Priority',
                  child: _buildPriorityRadioButtons(),
                ),
                _buildSection(
                  title: 'Category',
                  child: _buildDropdownField(
                    value: _category,
                    items: _categories,
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                ),
                const Gap(16),
                if (_isAttachingFile)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const CupertinoActivityIndicator(),
                      label: const Text('Attaching...'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.grey.shade200,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4.0,
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _attachFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach File'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey.shade200,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 4.0,
                    ),
                  ),
                if (_attachedFile != null) ...[
                  const Gap(10),
                  Text('Attached: ${_attachedFile!.name}'),
                ],
                const Gap(16),
                if (_isLoading)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4.0,
                      ),
                      child: const CupertinoActivityIndicator(color: Colors.white),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        if (_assignee == null || _assignee!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please assign the task to someone.')),
                          );
                        } else {
                          _createTicket();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 4.0,
                    ),
                    child: const Text('Create Ticket'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Gap(8),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSearchableDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  void _pickDueDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Widget _buildPriorityRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._priorities.map((priority) {
          return RadioListTile<String>(
            title: Text(priority),
            value: priority,
            groupValue: _priority,
            onChanged: (value) => setState(() => _priority = value!),
          );
        }),
      ],
    );
  }

  void _attachFile() async {
    setState(() => _isAttachingFile = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        setState(() => _attachedFile = result.files.first);
      }
    } finally {
      setState(() => _isAttachingFile = false);
    }
  }

  void _createTicket() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': _subjectController.text,
        'description': _descriptionController.text,
        'dueDate': _dueDate?.toString().split(' ')[0] ?? '',
        'priority': _priority,
        'category': _category,
        'assignee': _assignee,
        'organization': _organization,
        'contactEmail': _contactEmail,
        'attachedFileName': _attachedFile?.name,
        'status': 'Not Started',
        'timestamp': FieldValue.serverTimestamp(), // Add this line
      });
      Navigator.pop(context, true);
    } catch (e) {
      _logger.severe("Error creating ticket", e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error creating ticket')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}



















