import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final partyNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final contactController = TextEditingController();
  final whatsappController = TextEditingController();
  final addressController = TextEditingController();
  final discountController = TextEditingController();
  final gstController = TextEditingController();
  final udyamController = TextEditingController();

  final primaryEmailController = TextEditingController();
  final email2Controller = TextEditingController();
  final emailA1Controller = TextEditingController();
  final emailA2Controller = TextEditingController();
  final emailA3Controller = TextEditingController();
  final emailA4Controller = TextEditingController();

  final usernameController = TextEditingController();
  final agentNameController = TextEditingController();
  final agentContactController = TextEditingController();

  List<Map<String, String>> deliveryAgents = [];

  bool isLoading = false;

  Future<void> addCustomer() async {
    try {
      setState(() => isLoading = true);

      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('customers').doc(uid).set({
        // Existing fields (KEEP)
        "Party Names": partyNameController.text.trim(),
        "Email": emailController.text.trim(),
        "Password": passwordController.text.trim(),
        "Contact": contactController.text.trim(),
        "Whatsapp Number": whatsappController.text.trim(),
        "Address": addressController.text.trim(),
        "Discount": double.tryParse(discountController.text.trim()) ?? 0,

        // New fields
        "GST Number": gstController.text.trim(),
        "Udyam Number": udyamController.text.trim(),

        "Primary Email": primaryEmailController.text.trim(),
        "Email 2": email2Controller.text.trim(),
        "Email A1": emailA1Controller.text.trim(),
        "Email A2": emailA2Controller.text.trim(),
        "Email A3": emailA3Controller.text.trim(),
        "Email A4": emailA4Controller.text.trim(),


        "Username": usernameController.text.trim(),
        "DeliveryAgents": deliveryAgents,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer Added Successfully")),
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



  void addAgent() {
    if (agentNameController.text.trim().isEmpty) return;

    setState(() {
      deliveryAgents.add({
        "name": agentNameController.text.trim(),
        "contact": agentContactController.text.trim(),
      });
    });

    agentNameController.clear();
    agentContactController.clear();
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
            borderSide: const BorderSide(color: Color(0xFFF8D94B), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    partyNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    contactController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    discountController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2FF),
        elevation: 0,
        title: const Text(
          "Add Customer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField("Party Name", partyNameController),
            buildTextField("GST Number", gstController),
            buildTextField("Udyam Number", udyamController),
            buildTextField("Email", emailController),
            buildTextField("Username", usernameController),
            buildTextField("Password", passwordController),
            buildTextField("Contact", contactController, isNumber: true),
            buildTextField("Whatsapp Number", whatsappController, isNumber: true),
            buildTextField("Primary Email", primaryEmailController),
            buildTextField("Email 2", email2Controller),
            buildTextField("Email A1", emailA1Controller),
            buildTextField("Email A2", emailA2Controller),
            buildTextField("Email A3", emailA3Controller),
            buildTextField("Email A4", emailA4Controller),
            buildTextField("Address", addressController),
            buildTextField("Discount (%)", discountController, isNumber: true),
            // const SizedBox(height: 10),

            // const Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     // "Delivery Agents",
            //     style: TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 12),

            buildTextField(
              "Delivery Agent Name",
              agentNameController,
            ),

            buildTextField(
              "Delivery Agent Contact",
              agentContactController,
              isNumber: true,
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addAgent,
                child: const Text("Add Agent"),
              ),
            ),


            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: deliveryAgents.length,
              itemBuilder: (context, index) {
                final agent = deliveryAgents[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: Text(agent['name'] ?? ''),
                    subtitle: Text(agent['contact'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          deliveryAgents.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : addCustomer,
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
                  "Add Customer",
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