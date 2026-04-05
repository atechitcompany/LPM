import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    bool loggedIn = SessionManager.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8D94B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              height: 130,
              width: 130,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Image.asset(
                'assets/LPM.jpg',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Light Punch Maker",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xff46000A),
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Powered by A Tech",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                letterSpacing: 1.3,
              ),
            ),

            const SizedBox(height: 60),

            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xff46000A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}