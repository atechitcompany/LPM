import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'edit_user_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    final staffStream = FirebaseFirestore.instance.collection('Staff').snapshots();

    return staffStream.asyncMap((staffSnap) async {
      final customerSnap =
      await FirebaseFirestore.instance.collection('customers').get();

      final List<Map<String, dynamic>> users = [];

      for (final doc in staffSnap.docs) {
        final data = doc.data();

        users.add({
          "id": doc.id,
          "name": (data['Name'] ?? '').toString(),
          "email": (data['Email'] ?? '').toString(),
          "type": "Staff",
        });
      }

      for (final doc in customerSnap.docs) {
        final data = doc.data();

        users.add({
          "id": doc.id,
          "name": (data['Username'] ?? '').toString(),
          "email": (data['Email'] ?? '').toString(),
          "type": "Customer",
        });
      }

      return users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Admin Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value.trim().toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          Expanded(
            child: searchText.isEmpty
                ? _buildMainCards(context)
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildCard(
            context,
            title: "Staff",
            icon: Icons.people,
            color: Colors.blue,
            type: "Staff",
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: "Customers",
            icon: Icons.person,
            color: Colors.green,
            type: "Customer",
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getAllUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Something went wrong: ${snapshot.error}",
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allUsers = snapshot.data!;

        final filteredUsers = allUsers.where((user) {
          final name = (user['name'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final type = (user['type'] ?? '').toString().toLowerCase();

          return name.contains(searchText) ||
              email.contains(searchText) ||
              type.contains(searchText);
        }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      (user['name'] ?? '').toString().isNotEmpty
                          ? user['name'].toString()[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user['name'] ?? '').toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          (user['email'] ?? '').toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['type'] == "Staff"
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      user['type'],
                      style: TextStyle(
                        color: user['type'] == "Staff"
                            ? Colors.blue
                            : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

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
                      child: Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required String type,
      }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (context) {
            return _buildOptionsSheet(context, type: type);
          },
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_up),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSheet(BuildContext context, {required String type}) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text("Edit $type"),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin-users?type=$type');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text("Add New $type"),
            onTap: () {
              Navigator.pop(context);

              if (type == "Staff") {
                context.push('/add-staff');
              } else {
                context.push('/add-customer');
              }
            },
          ),
        ],
      ),
    );
  }
}