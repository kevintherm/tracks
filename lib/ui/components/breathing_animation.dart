import 'package:flutter/material.dart';
// Used for potential math ops, though not strictly needed here

class BreathingAnimation extends StatefulWidget {
  final Color color;
  const BreathingAnimation({super.key, required this.color});

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Define the controller duration (e.g., 4 seconds for one full breath cycle)
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
        )..repeat(
          reverse: true,
        ); // Start the animation and make it repeat indefinitely, reversing each time

    // 2. Create the animation that goes from 0.5 (small) to 1.0 (large)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Use a smooth curve for inhale/exhale
      ),
    );
  }

  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background color like your image
      body: Center(
        // 3. Use AnimatedBuilder to rebuild the widget on every animation tick
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SizedBox(
              width: 300,
              height: 300,
              // 4. Use Transform.scale to expand and shrink the Container
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // 5. Create the fading ripple effect using a RadialGradient
                    gradient: RadialGradient(
                      // Use the provided color
                      colors: [
                        widget.color.withAlpha(255), // Solid inner color
                        widget.color.withAlpha(128), // Mid-fade
                        widget.color.withAlpha(64), // Outer transparent
                      ],
                      // Controls how fast the colors/fade transition happens
                      stops: const [0.0, 0.7, 1.0],
                      center: Alignment.center,
                      focal: Alignment.center,
                    ),
                  ),
                  // Place your text/content on top
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
