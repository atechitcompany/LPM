import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lightatech/routes/app_route_config.dart';
import 'firebase_options.dart';
import 'common/responsive_shell.dart'; // 👈 ADD THIS

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      /// 👇 THIS IS THE KEY CHANGE
      routerConfig: AppRoutes.router,

      debugShowCheckedModeBanner: false,
    );
  }
}
