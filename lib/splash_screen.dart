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
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeInAnimation;

  int _currentCompanyNameIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fadeController.forward().then((_) => _startNameTransition());
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );
  }

  void _startNameTransition() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _currentCompanyNameIndex =
            (_currentCompanyNameIndex + 1) % widget.companyNames.length;
      });
      _fadeController.forward().then((_) {
        if (_currentCompanyNameIndex == widget.companyNames.length - 1) {
          _checkUserAuthentication();
        } else {
          _fadeController.reverse().then((_) {
            _startNameTransition();
          });
        }
      });
    });
  }

  Future<void> _checkUserAuthentication() async {
    try {
      // Capture the current BuildContext
      final context = this.context;

      await Future.delayed(const Duration(seconds: 2));
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      // Log the error or remove print in production
      // Use logging package like 'logger' instead of print in production
      debugPrint('Error checking authentication: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade800, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fade-in Company Logo
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          'lib/assets/rdbbanklogo.jpg', // Add your logo image here
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  // Company Name with smooth fade and slide transition
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: AnimatedSwitcher(
                      duration: const Duration(seconds: 2),
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
                  const SizedBox(height: 60.0),

                  // Loading spinner with fade-in effect
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: const CircularProgressIndicator(
                      strokeWidth: 4.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
