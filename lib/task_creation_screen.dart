import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino for the iOS-style indicator

class TicketCreationScreen extends StatefulWidget {
  final String? initialAssignee;

  const TicketCreationScreen({super.key, this.initialAssignee});

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
  bool _isLoading = false;
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

  // Define color palette
  final Color _primaryColor = const Color(0xFF003366); // Deep Navy Blue
  final Color _secondaryColor = const Color(0xFFF4F4F4); // Soft Gray
  final Color _accentColor = const Color(0xFF008080); // Teal
  final Color _textColor = const Color(0xFF333333); // Charcoal Gray

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserEmail().then((_) => _fetchUsers()); //nigga

    // Set the initial assignee if provided
    if (widget.initialAssignee != null) {
      _assignee = widget.initialAssignee;
    }

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
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      List<String> users = snapshot.docs.map((doc) {
        return (doc['displayName'] ?? 'No Name') as String;
      }).toList();

      if (user != null) {
        users.removeWhere((userName) => userName == user.displayName);
      }

      setState(() {
        _employees = users;
        if (_assignee != null && !_employees.contains(_assignee)) {
          _assignee = null;
        }
      });
    } catch (e) {
      _logger.severe("Error fetching users", e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _secondaryColor,
        title: Text(
          'Create New Ticket',
          style: TextStyle(color: _textColor),
        ),
        iconTheme: IconThemeData(color: _textColor), // Change back arrow color
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
                    title: Text(
                        'Due Date: ${_dueDate == null ? "Select Date" : _dueDate.toString().split(' ')[0]}'),
                    trailing:
                    Icon(Icons.calendar_today, color: _accentColor),
                    onTap: _pickDueDate,
                  ),
                ),
                _buildSection(
                  title: 'Assign To',
                  child: _employees.isEmpty
                      ? const CircularProgressIndicator()
                      : _buildDropdownField(
                    value: _assignee,
                    items: _employees,
                    onChanged: (value) => setState(() => _assignee = value),
                  ),
                ),
                _buildSection(
                  title: 'Priority',
                  child: _buildDropdownField(
                    value: _priority,
                    items: _priorities,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                ),
                _buildSection(
                  title: 'Category',
                  child: _buildDropdownField(
                    value: _category,
                    items: _categories,
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                ),
                const Gap(20),
                Center(
                  child: SizedBox(
                    width: double.infinity, // Make button full-width
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: _primaryColor, // Text color
                        padding: const EdgeInsets.symmetric(vertical: 16.0), // Increase vertical padding
                        textStyle: const TextStyle(
                          fontSize: 18, // Increase font size
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Rounded corners
                        ),
                      ),
                      onPressed: _isLoading ? null : _createTicket,
                      child: _isLoading
                          ? const CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 12.0, // Smaller radius for the loading indicator
                      )
                          : const Text('Create Ticket'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textColor, // Text color
          ),
        ),
        const Gap(8),
        child,
      ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _accentColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _createTicket() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final ticketData = {
          'organization': _organization,
          'contactEmail': _contactEmail,
          'subject': _subjectController.text,
          'description': _descriptionController.text,
          'dueDate': _dueDate?.toIso8601String(),
          'assignee': _assignee,
          'priority': _priority,
          'category': _category,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('tickets').add(ticketData);

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        _logger.severe("Error creating ticket", e);
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating ticket: $e')),
        );
      }
    }
  }
}
