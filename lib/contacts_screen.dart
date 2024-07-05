import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  ContactsScreenState createState() => ContactsScreenState();
}

class ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredContacts = [];
  List<Map<String, dynamic>> _allContacts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContacts);
    _fetchContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> contacts = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Document ID for potential updates or deletes
          'name': doc['displayName'] ?? 'No Name',
          'email': doc['email'] ?? 'No Email',
        };
      }).toList();

      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
      });
    } catch (e) {
      // Handle any errors
      print("Error fetching contacts: $e");
    }
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        return contact['name']!.toLowerCase().contains(query) ||
            contact['email']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _messageContact(String email) {
    // Implement messaging logic here
    print('Messaging contact with email: $email');
    // You can use Navigator to navigate to a new messaging screen if needed
    // Navigator.push(context, MaterialPageRoute(builder: (context) => MessagingScreen(email: email)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
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
            child: _filteredContacts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                var contact = _filteredContacts[index];
                return ListTile(
                  title: Text(contact['name']!),
                  subtitle: Text(contact['email']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.assignment_outlined),
                    onPressed: () {
                      _messageContact(contact['email']);
                    },
                  ),
                  onTap: () {
                    // Implement contact interaction functionality if needed
                    // For example, navigate to contact details screen
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






