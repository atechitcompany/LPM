import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    /// Splash delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/intro');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9D84A), // Yellow background
      body: Center(
        child: Text(
          "A TECH",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

