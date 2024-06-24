import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class CustomNavigation extends StatefulWidget {
  final String companyLogoPath; // Path to the logo image
  final List<String> companyNames; // List of company names to cycle through

  const CustomNavigation({
    super.key,
    required this.companyLogoPath,
    required this.companyNames,
  });

  @override
  CustomNavigationState createState() => CustomNavigationState();
}

class CustomNavigationState extends State<CustomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _opacityAnimation;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward().then((_) => _startNameTransition());
  }

  void _initializeAnimations() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startNameTransition() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.companyNames.length;
      });
      if (_currentIndex < widget.companyNames.length - 1) {
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
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e) {
      // Handle errors if needed
      print('Error checking authentication: $e');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1565C0), // Dark blue
                  Color(0xFF42A5F5), // Light blue
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: AnimatedBuilder(
                    animation: _logoScaleAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Image.asset(
                        widget.companyLogoPath,
                        height: 150.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),

                // Animated company names
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: Text(
                    widget.companyNames[_currentIndex],
                    key: ValueKey<int>(_currentIndex),
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

                const SizedBox(height: 100.0),

                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} //Splash Screen


