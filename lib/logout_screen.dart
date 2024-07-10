import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';  // Ensure this path is correct
import 'user_provider.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  LogoutScreenState createState() => LogoutScreenState();
}

class LogoutScreenState extends State<LogoutScreen> {
  User? _currentUser;
  String? _displayName;
  String? _email;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _displayName = user.displayName;
        _email = user.email;
        _photoURL = user.photoURL;
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      if (_currentUser != null) {
        // Optionally clear user data from Firestore (if needed)
        await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).delete();

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
      }
    } catch (e) {
      print("Error signing out: $e");
      // Optionally show a dialog or snack bar indicating failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: _currentUser == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_photoURL != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_photoURL!),
              ),
            const SizedBox(height: 15),
            Text(
              _displayName ?? 'No Name',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              _email ?? 'No Email',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                textStyle: const TextStyle(fontSize: 18),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shadowColor: Colors.black.withOpacity(0.2),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}



