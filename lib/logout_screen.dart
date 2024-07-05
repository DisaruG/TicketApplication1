import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';  // Ensure this path is correct
import 'user_provider.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Optionally clear user data from Firestore (if needed)
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).delete();

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
        title: const Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
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
      ),
    );
  }
}
