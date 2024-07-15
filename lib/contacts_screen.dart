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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchContacts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce mechanism
    if (_searchController.text.isEmpty) {
      _filterContacts('');
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_searchController.text == _searchController.value.text) {
          _filterContacts(_searchController.text);
        }
      });
    }
  }

  Future<void> _fetchContacts() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> contacts = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['displayName'] ?? 'No Name',
          'email': doc['email'] ?? 'No Email',
        };
      }).toList();

      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      // Handle any errors
      print("Error fetching contacts: $e");
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final nameLower = contact['name']!.toLowerCase();
        final emailLower = contact['email']!.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();
    });
  }

  void _messageContact(String email) {
    // Implement messaging logic here
    print('Messaging contact with email: $email');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => MessagingScreen(email: email)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildSearchBar(),
          _isLoading ? const Center(child: CircularProgressIndicator()) : buildContactList(),
        ],
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        title: const Text('Contacts', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget buildContactList() {
    return Expanded(
      child: ListView.builder(
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
              title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(contact['email']!),
              trailing: IconButton(
                icon: const Icon(Icons.assignment_outlined, color: Colors.blue),
                onPressed: () {
                  _messageContact(contact['email']);
                },
              ),
              onTap: () {
                // Implement contact interaction functionality if needed
              },
            ),
          );
        },
      ),
    );
  }
}













