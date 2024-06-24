import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Adjust the import path if needed
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RDB Tickets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CustomNavigation(
        companyLogoPath: 'lib/assets/rdbbanklogo.jpg',
        companyNames: ['RDB Tickets'],
      ),
    );
  }
}

