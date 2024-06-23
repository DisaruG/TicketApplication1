import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the HomeScreen widget

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF)], // Gradient background from light grey to white
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0), // Increased padding for better spacing
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image with shadow
                SizedBox(
                  width: 300, // Adjusted width for better fit
                  height: 300, // Adjusted height for better fit
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0), // Rounded corners for the image
                    child: Image.asset(
                      'lib/assets/bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Space between image and button
                // Large button for Google Sign-In
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to HomeScreen when the button is pressed
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      textStyle: const TextStyle(fontSize: 18), // Reduced text size for better readability
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shadowColor: Colors.black.withOpacity(0.2),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/download.png',
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        const Text('Sign in with Google'),
                      ],
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
}
