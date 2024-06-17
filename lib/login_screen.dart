import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background: blue to white
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Add padding for better layout
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder for an image with shadow
                Container(
                  width: 200, // Set width for the image container
                  height: 200, // Set height for the image container
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Grey background for placeholder
                    shape: BoxShape.circle, // Circular shape for image
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5), // Shadow position
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/login.png', // Replace with your image asset path
                      fit: BoxFit.cover, // Ensure the image covers the container
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Space between image and button
                // Large button for Google Sign-In with solid color
                SizedBox(
                  width: double.infinity, // Make button full width
                  height: 60, // Height of the button
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement Google Sign-In functionality
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      textStyle: const TextStyle(fontSize: 20), // Larger text size
                      foregroundColor: Colors.white, // Button text color
                      backgroundColor: Colors.blue, // Solid blue background color
                      shadowColor: Colors.black.withOpacity(0.2), // Shadow color
                      elevation: 5, // Elevation for button shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded edges with radius 10
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/download.png', // Replace with your Google logo asset path
                          height: 24, // Set the height for the image
                          fit: BoxFit.contain, // Fit the image within its bounds
                        ),
                        const SizedBox(width: 10), // Space between icon and text
                        const Text('Sign in with Google'), // Button text
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
