import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final contactController = TextEditingController();
  final roleController = TextEditingController();
  final keyController = TextEditingController();

  bool isLoading = false;

  Future<void> addStaff() async {
    try {
      setState(() => isLoading = true);

      // 🔥 STEP 1: Create Auth User
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // 🔥 STEP 2: Save in Firestore
      await FirebaseFirestore.instance.collection('Staff').doc(uid).set({
        "Name": nameController.text.trim(),
        "Email": emailController.text.trim(),
        "Password": passwordController.text.trim(),
        "Contact": contactController.text.trim(),
        "Role": roleController.text.trim(),
        "key": int.tryParse(keyController.text.trim()) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Staff Added Successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Staff")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField("Name", nameController),
            buildTextField("Email", emailController),
            buildTextField("Password", passwordController),
            buildTextField("Contact", contactController),
            buildTextField("Role", roleController),
            buildTextField("Key", keyController, isNumber: true),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : addStaff,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Add Staff"),
            ),
          ],
        ),
      ),
    );
  }
}