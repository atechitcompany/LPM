// lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';

class Home extends StatelessWidget {
  final Widget child;
  final String location;
  final List<dynamic>? departments;


  const Home({
    super.key,
    required this.child,
    required this.location,
    this.departments,
  });

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    if (location.startsWith('/map')) currentIndex = 1;
    else if (location.startsWith('/chat')) currentIndex = 2;
    else if (location.startsWith('/graph')) currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onNavTap: (index) {
          switch (index) {
            case 0: context.go('/dashboard'); break;
            case 1: context.go('/map'); break;
            case 2: context.go('/chat'); break;
            case 3: context.go('/graph'); break;
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}