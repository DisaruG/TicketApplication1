import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  PlatformFile? _attachedFile; // Use PlatformFile to store file details
  bool _isLoading = false;
  List<String> _employees = [];
  List<String> _organizations = ['Regional Development Bank']; // List for organizations

  final List<String> _contacts = [];
  final List<String> _categories = [
    'General',
    'Bug',
    'Feature',
    'Support',
    'Inquiry'
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchCurrentUserEmail();
    _organization = _organizations.first; // Set default organization
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
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      List<String> users = snapshot.docs.map((doc) {
        return (doc['displayName'] ?? 'No Name') as String;
      }).toList();

      setState(() {
        _employees = users;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  label: 'Organization',
                  value: _organization,
                  items: _organizations,
                  onChanged: (value) => setState(() => _organization = value),
                ),
                const Gap(16),
                _buildDropdownField(
                  label: 'Contact Email',
                  value: _contactEmail,
                  items: _contacts,
                  onChanged: (value) => setState(() => _contactEmail = value),
                ),
                const Gap(16),
                _buildTextField(
                  controller: _subjectController,
                  label: 'Subject',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                _buildTextField(
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
                const Gap(16),
                ListTile(
                  title: Text(
                      'Due Date: ${_dueDate == null ? "Select Date" : _dueDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                  onTap: _pickDueDate,
                ),
                const Gap(16),
                _buildDropdownField(
                  label: 'Assign To',
                  value: _assignee,
                  items: _employees,
                  onChanged: (value) => setState(() => _assignee = value),
                ),
                const Gap(16),
                _buildPriorityRadioButtons(),
                const Gap(16),
                _buildDropdownField(
                  label: 'Category',
                  value: _category,
                  items: _categories,
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const Gap(16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton.icon(
                    onPressed: _attachFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach File'),
                  ),
                if (_attachedFile != null) ...[
                  const Gap(10),
                  Text('Attached: ${_attachedFile!.name}'),
                ],
                const Gap(16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      _createTicket();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                    textStyle: const TextStyle(fontSize: 16),
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildPriorityRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority:', style: TextStyle(fontWeight: FontWeight.bold)),
        const Gap(8),
        Wrap(
          spacing: 20.0,
          children: _priorities.map((priority) {
            return _buildRadioButton(priority, _priority, (value) {
              setState(() {
                _priority = value!;
              });
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadioButton(
      String label, String groupValue, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }

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

  Future<void> _attachFile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _attachedFile = result.files.single;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createTicket() {
    var newTicket = {
      'subject': _subjectController.text,
      'description': _descriptionController.text,
      'dueDate': _dueDate,
      'priority': _priority,
      'category': _category,
      'assignee': _assignee,
      'organization': _organization,
      'contactEmail': _contactEmail,
      'attachedFile': _attachedFile,
    };
    // Handle the created ticket here (e.g., send to a backend or save locally)
    print(newTicket); // For now, just print the ticket details
    Navigator.pop(context); // Go back to the previous screen
  }
}







