import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart'; // Adjust the import path if needed
import 'firebase_options.dart';
import 'user_provider.dart'; // Import the UserProvider
import 'login_screen.dart'; // Import the login screen
import 'home_screen.dart'; // Import the home screen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'RDB Tickets',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(
          companyNames: ['RDB Tickets'],
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}



// More updates should be done 