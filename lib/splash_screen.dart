import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final List<String> companyNames; // List of company names to cycle through

  const SplashScreen({
    super.key,
    required this.companyNames,
  });

  @override
  CustomNavigationState createState() => CustomNavigationState();
}

class CustomNavigationState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundAnimation;

  int _currentCompanyNameIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward().then((_) => _startNameTransition());
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );


    _backgroundAnimation = ColorTween(
      begin: Colors.blue.shade700,
      end: Colors.blue.shade300,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  void _startNameTransition() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentCompanyNameIndex =
            (_currentCompanyNameIndex + 1) % widget.companyNames.length;
      });
      if (_currentCompanyNameIndex < widget.companyNames.length - 1) {
        _startNameTransition();
      } else {
        _checkUserAuthentication();
      }
    });
  }

  Future<void> _checkUserAuthentication() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('Error checking authentication: $e');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Set the plain color here
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            color: _backgroundAnimation.value, // Use plain color instead of gradient
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30.0),

                  // Animated company names
                  AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    child: Text(
                      widget.companyNames[_currentCompanyNameIndex],
                      key: ValueKey<int>(_currentCompanyNameIndex),
                      style: const TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Arial',
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black54,
                            offset: Offset(3.0, 3.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80.0),

                  // Custom Loading Indicator (Smaller)
                  const SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 4.0,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
