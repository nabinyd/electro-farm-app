import 'dart:async';
import 'package:electro_farm/main_screen.dart';
import 'package:electro_farm/custom_component/constant.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();

    // Navigate
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
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
    return Scaffold(
      body: Container(
        // 🌱 Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2E7D32), // deep green
              Color(0xFF66BB6A), // light green
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌿 Logo with animation + glow
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset('assets/icon/electrofarm-logo.png'),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🌱 Title (clean, no card)
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Agro",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "Bot",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🌾 Tagline
              Text(
                "Smart Farming with AI",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onPrimary,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              // 🌿 Modern Loader
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
