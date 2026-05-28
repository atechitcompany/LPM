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
  late TextEditingController whatsappController;
  late TextEditingController addressController;

  bool get isStaff => widget.user['type'] == "Staff";

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user['name'] ?? "");
    emailController = TextEditingController(text: widget.user['email'] ?? "");
    contactController =
        TextEditingController(text: widget.user['contact'] ?? "");
    whatsappController =
        TextEditingController(text: widget.user['whatsapp'] ?? "");
    addressController =
        TextEditingController(text: widget.user['address'] ?? "");
  }

  Future<void> updateUser() async {
    final collection = isStaff ? "Staff" : "customers";

    final Map<String, dynamic> updatedData = isStaff
        ? {
      "Name": nameController.text.trim(),
      "Email": emailController.text.trim(),
    }
        : {
      "Party Names": nameController.text.trim(),
      "Email": emailController.text.trim(),
      "Contact": contactController.text.trim(),
      "Whatsapp Number": whatsappController.text.trim(),
      "Address": addressController.text.trim(),
    };

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(widget.user['id'])
        .update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User Updated")),
    );

    Navigator.pop(context);
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
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
            borderSide: const BorderSide(color: Color(0xFFF8D94B), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    super.dispose();
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

            if (!isStaff) ...[
              buildTextField("Contact", contactController),
              buildTextField("Whatsapp Number", whatsappController),
              buildTextField("Address", addressController),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8D94B),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
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