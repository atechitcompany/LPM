import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lightatech/core/session/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool showPassword = false;
  bool isLoading = false;
  bool isGoogleLoading = false;
  bool showDepartmentForm = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ── After Google login, store the verified email here ──────────────────
  String? _googleEmail;

  final List<String> departments = [
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

  @override
  void initState() {
    super.initState();
    rememberMe = SessionManager.isRememberMe();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GOOGLE SIGN IN
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    setState(() => isGoogleLoading = true);

    try {
      // Step 1: Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        setState(() => isGoogleLoading = false);
        return;
      }

      // Step 2: Get auth details from the Google account
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Step 3: Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      final String googleEmail = googleUser.email;

      // Step 5: Check if this Google email exists in Staff collection
      final snapshot = await FirebaseFirestore.instance
          .collection('Staff')
          .where('Email', isEqualTo: googleEmail)
          .get();

      if (snapshot.docs.isEmpty) {
        // Email not registered as staff — sign out and show error
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "This Google account is not registered as staff. Contact admin."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Step 6: Valid staff — store email and show department picker
      _googleEmail = googleEmail;

      if (mounted) {
        setState(() => showDepartmentForm = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isGoogleLoading = false);
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EXISTING EMAIL/PASSWORD LOGIN — UNCHANGED
  // ──────────────────────────────────────────────────────────────────────────
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
          _googleEmail = null; // email/password login, not Google
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

  // ──────────────────────────────────────────────────────────────────────────
  // APPROVE — UNCHANGED, works for both login methods
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> approve() async {
    setState(() => isLoading = true);

    try {
      // Use Google email if signed in via Google, else use text field
      final String activeEmail =
          _googleEmail ?? emailController.text.trim();

      QuerySnapshot snapshot;

      if (_googleEmail != null) {
        // Google login — verify by email only (no password)
        snapshot = await FirebaseFirestore.instance
            .collection("Staff")
            .where('Email', isEqualTo: activeEmail)
            .get();
      } else {
        // Email/password login — verify both
        snapshot = await FirebaseFirestore.instance
            .collection("Staff")
            .where('Email', isEqualTo: activeEmail)
            .where('Password', isEqualTo: passwordController.text.trim())
            .get();
      }

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials")),
        );
        return;
      }

      final userData = snapshot.docs.first.data() as Map<String, dynamic>;
      final userDepartment = userData['Role'];

      if (selectedDepartments.length == 1 &&
          userDepartment.contains(selectedDepartments.first)) {
        navigateDepartment(selectedDepartments.first, activeEmail);
        return;
      }

      await FirebaseFirestore.instance.collection("Approvals").add({
        "Email": activeEmail,
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

  // ──────────────────────────────────────────────────────────────────────────
  // NAVIGATE — UNCHANGED logic, added email param for Google flow
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> navigateDepartment(String department, String email) async {
    await saveLoginLog(email: email, department: department);

    await SessionManager.saveSession(
      email: email,
      department: department,
      rememberMe: true,
    );

    context.go(
      '/dashboard',
      extra: {
        'department': department,
        'email': email,
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

  Widget safeIcon(IconData icon) {
    return Icon(icon, size: 18, color: Colors.grey);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────────────────
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

              // ── Logo ────────────────────────────────────────────────
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

              const Text(
                "Let's Sign In!",
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

              // ── Email field ─────────────────────────────────────────
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

              // ── Password field ──────────────────────────────────────
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
                  onTap: () =>
                      setState(() => showPassword = !showPassword),
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

              // ── Remember Me ─────────────────────────────────────────
              CheckboxListTile(
                value: rememberMe,
                onChanged: (v) => setState(() => rememberMe = v!),
                title: const Text("Remember Me"),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 35),

              // ── Sign In button ──────────────────────────────────────
              primaryButton(
                isLoading ? "Signing in..." : "Sign In",
                isLoading ? () {} : login,
              ),

              const SizedBox(height: 20),

              // ── Divider ─────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 20),

              // ── Google Sign-In button ───────────────────────────────
              GestureDetector(
                onTap: isGoogleLoading ? null : signInWithGoogle,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: isGoogleLoading
                      ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google "G" logo drawn with text
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border:
                          Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Center(
                          child: Text(
                            "G",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Sign in with Google",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202244),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Department picker (shown after successful login) ─────
              if (showDepartmentForm) ...[
                // Show which account is signed in via Google
                if (_googleEmail != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Signed in as $_googleEmail",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Text(
                  "Select Department",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700),
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
                primaryButton("Continue", approve),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputBox(
      {required Widget icon, required Widget child, Widget? trailing}) {
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

  Widget primaryButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF8D94B),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
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