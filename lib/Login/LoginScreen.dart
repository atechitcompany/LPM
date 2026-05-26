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

  // ✅ Store the full user data after first login check so we don't re-fetch
  Map<String, dynamic>? _loggedInUserData;

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

  // ✅ Only one department can be selected at a time (was allowing multi-select
  //    which broke the length == 1 check in approve())
  String? selectedDepartment;

  @override
  void initState() {
    super.initState();
    rememberMe = SessionManager.isRememberMe();
  }

  // ─── STEP 1: Verify credentials ──────────────────────────────────────────
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Staff')
          .where('Email', isEqualTo: emailController.text.trim())
          .where('Password', isEqualTo: passwordController.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
        return;
      }

      // ✅ Cache user data so approve() doesn't need another Firestore call
      _loggedInUserData = snapshot.docs.first.data();
      setState(() => showDepartmentForm = true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ─── STEP 2: Validate selected department and navigate ───────────────────
  Future<void> approve() async {
    if (selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a department")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userData = _loggedInUserData!;

      // ✅ BUG FIX: userData['Role'] can be a String OR a List depending on
      //    how it was saved in Firestore. Handle both cases safely.
      final dynamic roleRaw = userData['Role'];
      List<String> userRoles = [];

      if (roleRaw is String) {
        // Role stored as a plain string e.g. "Admin"
        userRoles = [roleRaw];
      } else if (roleRaw is List) {
        // Role stored as an array e.g. ["Admin", "Designer"]
        userRoles = List<String>.from(roleRaw);
      }

      // ✅ BUG FIX: Check with exact match (not substring search)
      if (userRoles.contains(selectedDepartment)) {
        // User is authorised — navigate directly, no approval needed
        await navigateDepartment(selectedDepartment!);
      } else {
        // User is requesting a department outside their assigned role
        await FirebaseFirestore.instance.collection("Approvals").add({
          "Email": emailController.text.trim(),
          "RequestedDepartments": [selectedDepartment],
          "UserCurrentDepartment": roleRaw,
          "Status": "Pending",
          "Timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request sent for approval")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ─── Navigate based on department ────────────────────────────────────────
  Future<void> navigateDepartment(String department) async {
    await saveLoginLog(
      email: emailController.text.trim(),
      department: department,
    );

    await SessionManager.saveSession(
      email: emailController.text.trim(),
      department: department,
      rememberMe: rememberMe,
    );

    if (!mounted) return;

    // Always go to /dashboard — the router redirects Admin to /admin-panel
    context.go(
      '/dashboard',
      extra: {
        'department': department,
        'email': emailController.text.trim(),
      },
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

  // ─── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF202244);
    final subTextColor =
    isDark ? Colors.grey.shade400 : const Color(0xFF545454);

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
                child: Container(
                  height: 150,
                  width: 150,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/LPM.jpg',
                      fit: BoxFit.cover,
                    ),
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
                title:
                Text("Remember Me", style: TextStyle(color: textColor)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 35),
              _buildPrimaryButton(
                "Sign In",
                isLoading ? null : login,
              ),
              const SizedBox(height: 40),

              // ── Department selection (shown after credentials verified) ──
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

                // ✅ Radio buttons instead of checkboxes — enforces single selection
                ...departments.map(
                      (dept) => RadioListTile<String>(
                    title: Text(dept, style: TextStyle(color: textColor)),
                    value: dept,
                    groupValue: selectedDepartment,
                    onChanged: (v) => setState(() => selectedDepartment = v),
                  ),
                ),

                const SizedBox(height: 20),
                _buildPrimaryButton(
                  "Continue",
                  isLoading ? null : approve,
                ),
                const SizedBox(height: 40),
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

  // ✅ Accept nullable VoidCallback so button can be disabled while loading
  Widget _buildPrimaryButton(String text, VoidCallback? onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF8D94B),
        minimumSize: const Size(double.infinity, 60),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: isLoading
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xff46000A),
        ),
      )
          : Text(
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