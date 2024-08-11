import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart'; // Ensure this path is correct
import 'user_provider.dart';
import 'home_screen.dart'; // Ensure this path is correct

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
      await FirebaseAuth.instance.signOut();
      Provider.of<UserProvider>(context, listen: false).signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      // Optionally show a dialog or snack bar indicating failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFF4F4F4), // Soft Gray background color
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20), // Add space between AppBar and content
            Expanded(
              child: Center(
                child: _currentUser == null
                    ? const CircularProgressIndicator()
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_photoURL != null)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_photoURL!),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      _displayName ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366), // Deep Navy Blue
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _email ?? 'No Email',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333), // Charcoal Gray
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _signOut(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 15.0,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF003366), // Deep Navy Blue
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
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Designed and Developed by Disaru Gunawardhana',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333), // Charcoal Gray
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
