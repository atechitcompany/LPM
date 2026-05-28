import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController contactController;
  late TextEditingController roleController;
  late TextEditingController passwordController;
  late TextEditingController aadhaarController;
  late TextEditingController panController;
  late TextEditingController discountController;

  bool isLoading = false;

  bool get isStaff => widget.user['type'] == "Staff";

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user['name'] ?? "");
    emailController = TextEditingController(text: widget.user['email'] ?? "");
    contactController = TextEditingController(text: widget.user['contact'] ?? "");
    roleController = TextEditingController(text: widget.user['role'] ?? "");
    passwordController = TextEditingController(text: widget.user['password'] ?? "");
    aadhaarController = TextEditingController(text: widget.user['aadhaar'] ?? "");
    panController = TextEditingController(text: widget.user['pan'] ?? "");
    discountController = TextEditingController(
      text: (widget.user['discount'] ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    roleController.dispose();
    passwordController.dispose();
    aadhaarController.dispose();
    panController.dispose();
    discountController.dispose();
    super.dispose();
  }

  Future<void> updateUser() async {
    try {
      setState(() => isLoading = true);

      final collection = isStaff ? "Staff" : "customers";

      if (isStaff) {
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.user['id'])
            .update({
          "Name": nameController.text.trim(),
          "Email": emailController.text.trim(),
          "Contact": contactController.text.trim(),
          "Role": roleController.text.trim(),
          "Password": passwordController.text.trim(),
          "Aadhaar": aadhaarController.text.trim(),
          "PAN": panController.text.trim(),
          "updatedAt": FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.user['id'])
            .update({
          "Party Names": nameController.text.trim(),
          "Email": emailController.text.trim(),
          "Contact": contactController.text.trim(),
          "Password": passwordController.text.trim(),
          "Discount": double.tryParse(discountController.text.trim()) ?? 0,
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User Updated")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget buildTextField(
      String label,
      TextEditingController controller, {
        bool isNumber = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFF8D94B),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.user['type'];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2FF),
        elevation: 0,
        title: Text(
          "Edit $type",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField(isStaff ? "Name" : "Party Name", nameController),
            buildTextField("Email", emailController),

            if (isStaff) ...[
              buildTextField("Contact", contactController, isNumber: true),
              buildTextField("Role", roleController),
              buildTextField("Password", passwordController),
              buildTextField("Aadhaar", aadhaarController, isNumber: true),
              buildTextField("PAN", panController),
            ] else ...[
              buildTextField("Contact", contactController, isNumber: true),
              buildTextField("Password", passwordController),
              buildTextField("Discount (%)", discountController, isNumber: true),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8D94B),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                  "Update",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}