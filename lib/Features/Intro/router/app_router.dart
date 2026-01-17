import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/intro_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',   // your normal home route can stay later

  routes: [
    /// Splash when Share is clicked
    GoRoute(
      path: '/intro/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    /// Intro pages
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        "Page Not Found",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    ),
  ),
);
