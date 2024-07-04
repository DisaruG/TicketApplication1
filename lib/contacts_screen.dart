import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Ensure this is the correct path to your login screen
import 'package:provider/provider.dart';
import 'user_provider.dart';

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

  Future<void> _deleteContact(String contactId, String email) async {
    try {
      // Delete user data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(contactId).delete();

      // If the user to be deleted is the current user, sign out
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email == email) {
        // Sign out from FirebaseAuth
        await FirebaseAuth.instance.signOut();

        // Clear user data from the provider
        Provider.of<UserProvider>(context, listen: false).signOut();

        // Navigate to the login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      } else {
        // If not the current user, simply remove them from the contacts list
        setState(() {
          _allContacts.removeWhere((contact) => contact['id'] == contactId);
          _filteredContacts = _allContacts;
        });
      }
    } catch (e) {
      print("Error deleting contact: $e");
      // Optionally show a dialog or snack bar indicating failure
    }
  }

  void _messageContact(String email) {
    // Implement messaging logic here
    print('Messaging contact with email: $email');
  }

  void _showContactOptions(String contactId, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete and Logout'),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  _deleteContact(contactId, email);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Message Contact'),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  _messageContact(email);
                },
              ),
            ],
          ),
        );
      },
    );
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
                  onTap: () {
                    // Implement contact interaction functionality
                    // For example, navigate to contact details screen
                  },
                  onLongPress: () {
                    _showContactOptions(contact['id'], contact['email']);
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




