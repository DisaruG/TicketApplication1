import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  ContactsScreenState createState() => ContactsScreenState();
}

class ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _contacts = [
    {'name': 'John Doe', 'email': 'john.doe@example.com'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com'},
    {'name': 'Alice Johnson', 'email': 'alice.johnson@example.com'},
    {'name': 'Bob Lee', 'email': 'bob.lee@example.com'},
  ];

  List<Map<String, String>> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    // Initially, display all contacts
    _filteredContacts = _contacts;
    // Add a listener to the search field to update the list as the user types
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        return contact['name']!.toLowerCase().contains(query) ||
            contact['email']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Contacts',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                var contact = _filteredContacts[index];
                return ListTile(
                  title: Text(contact['name']!),
                  subtitle: Text(contact['email']!),
                  onTap: () {
                    // Implement contact interaction functionality
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
