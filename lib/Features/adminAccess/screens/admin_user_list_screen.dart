import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'edit_user_screen.dart';

class AdminUserListScreen extends StatefulWidget {
  final String type;

  const AdminUserListScreen({super.key, required this.type});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> fetchUsers() {
    final bool isStaff = widget.type == "Staff";
    final String collection = isStaff ? "Staff" : "customers";

    return FirebaseFirestore.instance.collection(collection).snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          if (isStaff) {
            return {
              "id": doc.id,
              "name": (data["Name"] ?? "").toString(),
              "email": (data["Email"] ?? "").toString(),
              "type": "Staff",
              "role": (data["Role"] ?? "").toString(),
            };
          } else {
            return {
              "id": doc.id,
              "name": (data["Party Names"] ?? "").toString(),
              "email": (data["Email"] ?? "").toString(),
              "contact": (data["Contact"] ?? "").toString(),
              "whatsapp": (data["Whatsapp Number"] ?? "").toString(),
              "address": (data["Address"] ?? "").toString(),
              "password": (data["Password"] ?? "").toString(),
              "type": "Customer",
              "role": "-",
            };
          }
        }).toList();
      },
    );
  }

  Future<void> deleteUser(Map<String, dynamic> user) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: Text(
            "Are you sure you want to delete ${user['name']}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final collection = user['type'] == "Staff" ? "Staff" : "customers";

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(user['id'])
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User Deleted")),
    );
  }

  void goToAddUser() {
    if (widget.type == "Staff") {
      context.push('/add-staff');
    } else {
      context.push('/add-customer');
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchText = searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: AppBar(
        title: Text("${widget.type} Users"),
        backgroundColor: const Color(0xFFEEF2FF),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: goToAddUser,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8D94B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "Search user...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Error: ${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.where((user) {
                  final name = user['name'].toString().toLowerCase();
                  final email = user['email'].toString().toLowerCase();
                  final contact = (user['contact'] ?? "").toString().toLowerCase();
                  final whatsapp = (user['whatsapp'] ?? "").toString().toLowerCase();

                  return name.contains(searchText) ||
                      email.contains(searchText) ||
                      contact.contains(searchText) ||
                      whatsapp.contains(searchText);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    final name = user['name'].toString();
                    final email = user['email'].toString();

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : "No Name",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  email.isNotEmpty ? email : "No Email",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditUserScreen(user: user),
                                ),
                              );
                            },
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => deleteUser(user),
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}