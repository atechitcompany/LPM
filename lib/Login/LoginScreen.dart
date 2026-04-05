import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:lightatech/core/theme/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool showPassword = false;
  bool isLoading = false;
  bool showDepartmentForm = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final List<String> departments = [
    "Admin",
    "Designer",
    "Account",
    "AutoBending",
    "Delivery",
    "Emboss",
    "Lasercut",
    "ManualBending",
    "Rubber",
  ];

  List<String> selectedDepartments = [];

  @override
  void initState() {
    super.initState();
    rememberMe = SessionManager.isRememberMe();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Staff')
          .get();

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> approve() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Staff")
          .where('Email', isEqualTo: emailController.text.trim())
          .where('Password', isEqualTo: passwordController.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
        return;
      }

      final userData = snapshot.docs.first.data();
      final userDepartment = userData['Role'];

      if (selectedDepartments.length == 1 &&
          userDepartment.contains(selectedDepartments.first)) {
        navigateDepartment(selectedDepartments.first);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> navigateDepartment(String department) async {
    await saveLoginLog(
      email: emailController.text.trim(),
      department: department,
    );

    await SessionManager.saveSession(
      email: emailController.text.trim(),
      department: department,
      rememberMe: true,
    );

    context.go(
      '/dashboard',
      extra: {'department': department, 'email': emailController.text.trim()},
    );
  }

  Future<void> saveLoginLog({
    required String email,
    required String department,
  }) async {
    await FirebaseFirestore.instance.collection('LoginLogs').add({
      'Email': email,
      'Department': department,
      'LoginTime': FieldValue.serverTimestamp(),
    });
  }

  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF202244);
    final subTextColor = isDark
        ? Colors.grey.shade400
        : const Color(0xFF545454);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFFF8D94B),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Color(0xff46000A),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                "Let's Sign In!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Login to your account to continue",
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 40),
              _buildInputBox(
                icon: Icons.email,
                child: TextField(
                  controller: emailController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                    hintStyle: TextStyle(color: subTextColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInputBox(
                icon: Icons.lock,
                child: TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                    hintStyle: TextStyle(color: subTextColor),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () => setState(() => showPassword = !showPassword),
                  child: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: subTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              CheckboxListTile(
                value: rememberMe,
                onChanged: (v) => setState(() => rememberMe = v!),
                title: Text("Remember Me", style: TextStyle(color: textColor)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 35),
              _buildPrimaryButton("Sign In", login),
              const SizedBox(height: 40),
              if (showDepartmentForm) ...[
                Text(
                  "Select Department",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                ...departments.map(
                  (dept) => CheckboxListTile(
                    title: Text(dept, style: TextStyle(color: textColor)),
                    value: selectedDepartments.contains(dept),
                    onChanged: (v) {
                      setState(() {
                        v!
                            ? selectedDepartments.add(dept)
                            : selectedDepartments.remove(dept);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildPrimaryButton("Continue", approve),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black12,
            blurRadius: 8,
          ),
        ],
        color: cardColor,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(child: child),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF8D94B),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
