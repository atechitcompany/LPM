import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lightatech/routes/app_route_config.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox('sessionBox');
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

        // ✅ FIX: primary must NOT be white
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF8D94B), // used by checkbox & cursor
          onPrimary: Colors.black,

          background: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),

        scaffoldBackgroundColor: Colors.white,

        // ✅ FIX: cursor + selection visibility
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionHandleColor: Colors.black,
        ),

        // 🎯 ONLY APPBAR YELLOW (unchanged)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8D94B),
          surfaceTintColor: Colors.transparent,
          elevation: 0,

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
