import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_constants.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  TextEditingController Emailcontroller = TextEditingController();
  TextEditingController Passwordcontroller = TextEditingController();
  String? Role;
  String? DepartmentType;
  bool isLoading = false;
  bool ShowDepartmentform = false;
  bool TrueDepartment = false;
  List<String> departments = [
    "Admin",
    "Designer",
    "Account",
    "Autobending",
    "Delivery",
    "Emboss",
    "Lasercut",
    "ManualBending",
    "Rubber",
  ];

  List<String> selectedDepartments = [];

  Future<void> login() async {
    if (Emailcontroller.text.trim().isEmpty ||
        Passwordcontroller.text.trim().isEmpty ||
        Role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields before logging in"),
        ),
      );
      return;
    } else {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Employee')
            .get();
        bool found = false;
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['Email'] == Emailcontroller.text.trim() &&
              data['Password'] == Passwordcontroller.text.trim()) {
            found = true;
            setState(() => ShowDepartmentform = true);
            break;
          }
        }

        if (!found) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Enter valid email and password")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error : $e")));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> approve() async {
    setState(() => isLoading = true);

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Employee")
          .where('Email', isEqualTo: Emailcontroller.text.trim())
          .where('Password', isEqualTo: Passwordcontroller.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
        return;
      }

      final userData = snapshot.docs.first.data() as Map<String, dynamic>;
      final userDepartment = userData['Department'];

      if (selectedDepartments.length == 1) {
        String selected = selectedDepartments.first;

        if (userDepartment.contains(selected)) {
          NavigateDepartment(selectedDepartments);
          return;
        }
      }

      QuerySnapshot existingRequests = await FirebaseFirestore.instance
          .collection("Approvals")
          .where("Email", isEqualTo: Emailcontroller.text.trim())
          .get();

      await FirebaseFirestore.instance.collection("Approvals").add({
        "Email": Emailcontroller.text.trim(),
        "RequestedDepartments": selectedDepartments,
        "UserCurrentDepartment": userDepartment,
        "Status": "Pending",
        "Timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request submitted. Wait for admin approval."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void NavigateDepartment(List<dynamic> departments) {
    if (departments.contains("Admin")) {
      GoRouter.of(context).pushNamed(AppRoutesName.Adminroutename);
      return;
    }

    GoRouter.of(
      context,
    ).pushNamed(AppRoutesName.DepartmentCommonPage, extra: departments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              children: [
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 50,
                            color: Colors.deepPurple.shade400,
                          ),
                          SizedBox(height: 10),
                          Text('Login', style: TextStyle(fontSize: 30)),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: Emailcontroller,
                            decoration: InputDecoration(
                              hint: Text("Enter your Email"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: Passwordcontroller,
                            decoration: InputDecoration(
                              hint: Text("Enter your Password"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 75,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: login,
                              child: Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (ShowDepartmentform) ...[
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      elevation: 10,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                "Select Department",
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(height: 20),
                              Column(
                                children: departments.map((dept) {
                                  return CheckboxListTile(
                                    title: Text(dept),
                                    value: selectedDepartments.contains(dept),
                                    onChanged: (bool? checked) {
                                      setState(() {
                                        if (checked!) {
                                          selectedDepartments.add(dept);
                                        } else {
                                          selectedDepartments.remove(dept);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                height: 75,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: approve,
                                  child: Text('Login'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
