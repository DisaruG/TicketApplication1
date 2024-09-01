import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:ticketapplication/task_creation_screen.dart'; // Import for debouncing

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  ContactsScreenState createState() => ContactsScreenState();
}

class ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredContacts = [];
  List<Map<String, dynamic>> _allContacts = [];
  Timer? _debounce; // Timer for debouncing

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel(); // Cancel debounce timer
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterContacts(_searchController.text);
    });
  }

  void _filterContacts(String query) {
    final searchLower = query.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final nameLower = contact['name']!.toLowerCase();
        final emailLower = contact['email']!.toLowerCase();
        return nameLower.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();
    });
  }

  void _assignToContact(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketCreationScreen(
          initialAssignee: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                _allContacts = snapshot.data!.docs.map((doc) {
                  return {
                    'id': doc.id,
                    'name': doc['displayName'] ?? 'No Name',
                    'email': doc['email'] ?? 'No Email',
                  };
                }).toList();

                _filteredContacts = _allContacts;
                return buildContactList();
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: const Text('Contacts', style: TextStyle(color: Color(0xFF333333))), // Charcoal Gray
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search Contacts',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF003366)), // Deep Navy Blue
          filled: true,
          fillColor: const Color(0xFFF4F4F4), // Soft Gray
        ),
      ),
    );
  }

  Widget buildContactList() {
    return ListView.separated(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4.0,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(contact['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))), // Charcoal Gray
            subtitle: Text(contact['email']!),
            trailing: IconButton(
              icon: const Icon(Icons.assignment_outlined, color: Color(0xFF003366)), // Deep Navy Blue
              onPressed: () {
                _assignToContact(contact['name']!);
              },
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1.0),
    );
  }
}
