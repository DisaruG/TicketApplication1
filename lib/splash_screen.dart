import 'package:flutter/material.dart';

class CustomNavigation extends StatefulWidget {
  final String companyLogoPath; // Path to the logo image
  final List<String> companyNames; // List of company names to cycle through
  final Widget nextScreen; // Next screen to navigate to

  const CustomNavigation({
    super.key,
    required this.companyLogoPath,
    required this.companyNames,
    required this.nextScreen,
  });

  @override
  CustomNavigationState createState() => CustomNavigationState();
}

class CustomNavigationState extends State<CustomNavigation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _logoScaleAnimation;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) {
      _startNameTransition();
    });
  }

  void _startNameTransition() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.companyNames.length;
      });
      if (_currentIndex < widget.companyNames.length - 1) {
        _startNameTransition();
      } else {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Stack(
        children: [
          Container(
            color: Colors.blue, // Background color
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                AnimatedBuilder(
                  animation: _logoScaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Image.asset(
                      widget.companyLogoPath,
                      height: 150.0, // Adjust logo size as needed
                    ),
                  ),
                ),
                const SizedBox(height: 30.0), // Space between logo and company name

                // Animated company names
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: Text(
                    widget.companyNames[_currentIndex],
                    key: ValueKey<int>(_currentIndex),
                    style: TextStyle(
                      fontSize: 36.0, // Adjust font size
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial', // Use a custom font if needed
                      decoration: TextDecoration.none, // Remove underlining
                      foreground: Paint()..shader = const LinearGradient(
                        colors: <Color>[Colors.blue, Colors.white],
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)), // Gradient effect
                      shadows: const [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black54,
                          offset: Offset(3.0, 3.0),
                        ),
                      ], // Shadow effect
                    ),
                  ),
                ),
                const SizedBox(height: 100.0), // More space to push the loading animation lower

                // Loading indicator
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}