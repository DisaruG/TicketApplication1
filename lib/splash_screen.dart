import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;
  late AnimationController _nameController;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  int _currentCompanyNameIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _backgroundController.forward().then((_) => _startNameTransition());
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Shorter duration for background animation
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: Colors.purple.shade600,
      end: Colors.blue.shade500,
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.linear,
      ),
    );

    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Shorter duration for name animation
    );


    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Shorter duration for loading animation
    )..repeat();

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startNameTransition() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentCompanyNameIndex =
            (_currentCompanyNameIndex + 1) % widget.companyNames.length;
      });
      _nameController.forward().then((_) {
        _nameController.reverse().then((_) {
          if (_currentCompanyNameIndex < widget.companyNames.length - 1) {
            _startNameTransition();
          } else {
            _checkUserAuthentication();
          }
        });
      });
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
    _backgroundController.dispose();
    _nameController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_backgroundAnimation.value!, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 1.0],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated company names with sliding effect
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(_nameController),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300), // Faster transition for company names
                      child: Text(
                        widget.companyNames[_currentCompanyNameIndex],
                        key: ValueKey<int>(_currentCompanyNameIndex),
                        style: const TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
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
                  ),
                  const SizedBox(height: 60.0), // Adjusted spacing

                  // Custom iOS-style Loading Animation
                  SizedBox(
                    width: 60.0,
                    height: 60.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _loadingAnimation.value,
                          strokeWidth: 6.0,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: Colors.black26,
                        ),
                        Positioned(
                          child: RotationTransition(
                            turns: _loadingController,
                            child: const Icon(
                              CupertinoIcons.refresh,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ],
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
