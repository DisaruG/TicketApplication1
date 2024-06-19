import 'package:flutter/material.dart';
import 'package:ticketapplication/splash_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CustomNavigation(companyLogoPath: "lib/assets/rdbbanklogo.jpg", companyNames: ["RDB Tickets"], nextScreen: LoginScreen()),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}