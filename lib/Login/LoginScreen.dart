import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool showPassword = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool showDepartmentForm = false;

  List<String> departments = [
    "Admin",
    "Designer",
    "Account",
    "AutoBending",
    "Delivery",
    "Emboss",
    "Lasercut",
    "ManualBending",
    "Rubber"
  ];

  List<String> selectedDepartments = [];

  // 🔐 LOGIN
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('Staff').get();

      bool found = false;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['Email'] == emailController.text.trim() &&
            data['Password'] == passwordController.text.trim()) {
          found = true;
          setState(() => showDepartmentForm = true);
          break;
        }
      }

      if (!found) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ APPROVE
  Future<void> approve() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Staff")
          .where('Email', isEqualTo: emailController.text.trim())
          .where('Password', isEqualTo: passwordController.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials")),
        );
        return;
      }

      final userData = snapshot.docs.first.data();
      final userDepartment = userData['Role'];

      if (selectedDepartments.length == 1 &&
          userDepartment.contains(selectedDepartments.first)) {
        navigateDepartment(selectedDepartments);
        return;
      }

      await FirebaseFirestore.instance.collection("Approvals").add({
        "Email": emailController.text.trim(),
        "RequestedDepartments": selectedDepartments,
        "UserCurrentDepartment": userDepartment,
        "Status": "Pending",
        "Timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request sent for approval")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void navigateDepartment(List<dynamic> departments) {
    if (departments.contains("Admin")) {
      context.go('/admin');
    } else {
      context.go('/dashboard', extra: departments);
    }
  }

  // 🖼️ SAFE ICON (NO OVERFLOW, NO 403)
  Widget safeIcon(IconData fallback) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Icon(fallback, size: 18, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              /// LOGO
              Center(
                child: SizedBox(
                  height: 90,
                  child: Icon(Icons.account_circle,
                      size: 90, color: Colors.grey.shade400),
                ),
              ),

              const SizedBox(height: 50),

              const Text(
                "Let’s Sign In!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202244),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to your account to continue",
                style: TextStyle(fontSize: 14, color: Color(0xFF545454)),
              ),

              const SizedBox(height: 40),

              /// EMAIL
              inputBox(
                icon: safeIcon(Icons.email),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              inputBox(
                icon: safeIcon(Icons.lock),
                child: TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () => setState(() => showPassword = !showPassword),
                  child: Icon(
                    showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              CheckboxListTile(
                value: rememberMe,
                onChanged: (v) => setState(() => rememberMe = v!),
                title: const Text("Remember Me"),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 35),

              /// SIGN IN BUTTON
              primaryButton("Sign In", login),

              const SizedBox(height: 40),

              if (showDepartmentForm) ...[
                const Text(
                  "Select Department",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                ...departments.map((dept) => CheckboxListTile(
                  title: Text(dept),
                  value: selectedDepartments.contains(dept),
                  onChanged: (v) {
                    setState(() {
                      v!
                          ? selectedDepartments.add(dept)
                          : selectedDepartments.remove(dept);
                    });
                  },
                )),
                const SizedBox(height: 20),
                primaryButton("Log In", approve),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 INPUT BOX
  Widget inputBox(
      {required Widget icon,
        required Widget child,
        Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
        color: Colors.white,
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(child: child),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  /// 🔹 PRIMARY BUTTON
  Widget primaryButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF8D94B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xff46000A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
