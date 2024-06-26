import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TicketCreationScreen extends StatefulWidget {
  const TicketCreationScreen({super.key});

  @override
  TicketCreationScreenState createState() => TicketCreationScreenState();
}

class TicketCreationScreenState extends State<TicketCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Low';
  String _category = 'General';
  String? _assignee;
  String? _organization;
  String? _contactEmail;
  String? _attachedFile;
  bool _isLoading = false;

  final List<String> _organizations = ['Org A', 'Org B', 'Org C'];
  final List<String> _employees = ['John Doe', 'Jane Smith', 'Alice Johnson', 'Bob Lee'];
  final List<String> _contacts = ['john@example.com', 'jane@example.com', 'alice@example.com', 'bob@example.com'];
  final List<String> _categories = ['General', 'Bug', 'Feature', 'Support', 'Inquiry'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

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
                _buildDropdownField(
                  label: 'Contact Email',
                  value: _contactEmail,
                  items: _contacts,
                  onChanged: (value) => setState(() => _contactEmail = value),
                ),
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
                const SizedBox(height: 20),
                ListTile(
                  title: Text('Due Date: ${_dueDate == null ? "Select Date" : _dueDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                  onTap: _pickDueDate,
                ),
                _buildDropdownField(
                  label: 'Assign To',
                  value: _assignee,
                  items: _employees,
                  onChanged: (value) => setState(() => _assignee = value),
                ),
                const SizedBox(height: 20),
                _buildPriorityRadioButtons(),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'Category',
                  value: _category,
                  items: _categories,
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton.icon(
                    onPressed: _attachFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach File'),
                  ),
                if (_attachedFile != null) ...[
                  const SizedBox(height: 10),
                  Text('Attached: $_attachedFile'),
                ],
                const SizedBox(height: 20),
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
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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

  Widget _buildRadioButton(String label, String groupValue, ValueChanged<String?> onChanged) {
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
          _attachedFile = result.files.single.name;
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
