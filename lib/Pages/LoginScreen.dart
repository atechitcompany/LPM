import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_constants.dart';

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
  String? Role;
  String? DepartmentType;
  bool isLoading=false;
  bool ShowDepartmentform=false;
  bool TrueDepartment=false;
  List<String> departments = [
    "Admin",
    "Designer",
    "Account",
    "Autobending",
    "Delivery",
    "Emboss",
    "Lasercut",
    "ManualBending",
    "Rubber"
  ];
  List<String> selectedDepartments = [];
  Future <void> login() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields before logging in")),
      );
      return;
    }
    else{
      setState(() => isLoading = true);
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
            'Staff').get();
        bool found = false;
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['Email'] == emailController.text.trim() &&
              data['Password'] == passwordController.text.trim()) {
            found = true;
              setState(() => ShowDepartmentform = true);
            break;
          }
        }
        if (!found) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Enter valid email and password")));
        }
      }
      catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error : $e")));
      }
      finally {
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
          .collection("Staff")
          .where('Email', isEqualTo: emailController.text.trim())
          .where('Password', isEqualTo: passwordController.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
        return;
      }

      final userData = snapshot.docs.first.data() as Map<String, dynamic>;
      final userDepartment = userData['Role'];

      if (selectedDepartments.length == 1) {
        String selected = selectedDepartments.first;

        if (userDepartment.contains(selected)) {
          NavigateDepartment(selectedDepartments);
          return;
        }
      }

      QuerySnapshot existingRequests = await FirebaseFirestore.instance
          .collection("Approvals")
          .where("Email", isEqualTo: emailController.text.trim())
          .get();

      await FirebaseFirestore.instance.collection("Approvals").add({
        "Email": emailController.text.trim(),
        "RequestedDepartments": selectedDepartments,
        "UserCurrentDepartment": userDepartment,
        "Status": "Pending",
        "Timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request submitted. Wait for admin approval.")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void NavigateDepartment(List<dynamic> departments) {
    if (departments.contains("Admin")) {
      GoRouter.of(context).pushNamed(AppRoutesName.Adminroutename);
      return;
    }

    GoRouter.of(context).pushNamed(
      AppRoutesName.DepartmentCommonPage,
      extra: departments,
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
                  child: Image.network(
                    "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/sbsrv9nhWM/tgt9jpg2_expires_30_days.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              Text(
                "Let’s Sign In.!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202244),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Login to Your Account to Continue",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF545454),
                ),
              ),

              const SizedBox(height: 40),

              /// EMAIL FIELD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Image.network(
                      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/sbsrv9nhWM/ctw93or0_expires_30_days.png",
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// PASSWORD FIELD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Image.network(
                      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/sbsrv9nhWM/4a9h2idt_expires_30_days.png",
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      child: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              /// ROLE DROPDOWN

              const SizedBox(height: 18),
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (val) => setState(() => rememberMe = val!),
                    activeColor: Color(0xFF202244),
                  ),
                  const Text(
                    "Remember Me",
                    style: TextStyle(color: Color(0xFF545454)),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              /// SIGN IN BUTTON
            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFF8D94B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              child: Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    /// CENTER TEXT
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xff46000A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    /// ARROW ON THE RIGHT
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF46000A),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),




            const SizedBox(height: 40),

              if (ShowDepartmentform) ...[
                const SizedBox(height: 30),

                /// WRAPPER CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// TITLE
                      const Text(
                        "Select Department",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202244),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// CHECKBOX LIST
                      Column(
                        children: departments.map((dept) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                dept,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF202244),
                                ),
                              ),
                              value: selectedDepartments.contains(dept),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Color(0xFF202244),
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked!) {
                                    selectedDepartments.add(dept);
                                  } else {
                                    selectedDepartments.remove(dept);
                                  }
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 25),

                      /// LOGIN/SUBMIT BUTTON (Matching UI)
                      ElevatedButton(
                        onPressed: approve,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFFF8D94B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [

                              /// CENTER TEXT
                              const Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xff46000A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              /// ARROW ON THE RIGHT
                              Positioned(
                                right: 0,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFF46000A),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ]

            ],
          ),
        ),
      ),
    );
  }
}
