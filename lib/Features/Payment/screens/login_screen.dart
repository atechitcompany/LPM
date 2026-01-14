import 'dart:async'; // For Timeout
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  // --- FAST LOGIN LOGIC ---
  void _login() async {
    String email = _emailCtrl.text.trim();
    String password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Email & Password")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. FAST QUERY WITH TIMEOUT (5 Seconds)
      // Agar 5 second me jawab nahi aya, to error throw karega
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw "Internet connection is slow. Please try again.";
      });

      if (querySnapshot.docs.isEmpty) {
        throw "User not found! Contact Admin.";
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();

      // 2. CHECK PASSWORD
      // Master Password '123456' OR Real Password
      if (password == "123456" || (userData['password'] == password)) {

        // 3. SAVE SESSION LOCALLY
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userDoc.id);
        await prefs.setString('userRole', userData['role'] ?? 'Employee');
        await prefs.setString('userName', userData['name'] ?? 'User');
        await prefs.setString('userEmail', userData['email'] ?? email); // Save Email too

        if (mounted) {
          // 4. GO TO HOME (Replacement prevents back button)
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      } else {
        throw "Incorrect Password";
      }

    } catch (e) {
      if (mounted) {
        // Clean error message
        String msg = e.toString();
        if(msg.contains("Timeout")) msg = "Slow Internet. Try again.";

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.business_center, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text("A TECH CRM", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
              const Center(
                child: Text("Secure Login", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 40),

              // EMAIL
              const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "staff@atech.com",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),

              // PASSWORD
              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: "••••••",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),

              const SizedBox(height: 30),

              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDD835),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
              const Center(child: Text("Powered by A Tech IT Solution", style: TextStyle(fontSize: 12, color: Colors.grey))),
            ],
          ),
        ),
      ),
    );
  }
}