import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lightatech/routes/app_route_config.dart';
import 'firebase_options.dart';
import 'common/responsive_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        // 🌍 GLOBAL COLORS → PURE WHITE
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
          background: Colors.white,
          surface: Colors.white,
        ),

        scaffoldBackgroundColor: Colors.white,

        // 🎯 ONLY APPBAR YELLOW
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8D94B),
          surfaceTintColor: Colors.transparent, // 🚨 removes dull overlay
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      routerConfig: AppRoutes.router,
    );
  }
}
