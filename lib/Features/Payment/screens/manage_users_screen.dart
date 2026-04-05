import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_user_screen.dart'; // Next step me update karenge

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  void _deleteUser(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Delete User?"),
          content: const Text("Is user ka access hamesha ke liye khatam ho jayega."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
          ],
        )
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserScreen())),
        label: const Text("Add New User"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (ctx, i) {
              final data = users[i].data() as Map<String, dynamic>;
              final id = users[i].id;
              final name = data['name'] ?? 'Unknown';
              final role = data['role'] ?? 'Employee';
              final email = data['email'] ?? '-';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: role == 'Admin' ? Colors.black : Colors.blue,
                    child: Icon(role == 'Admin' ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("$email • $role"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Edit Mode me open karein
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddUserScreen(userId: id, userData: data)));
                        },
                      ),
                      if (role != 'Admin') // Admin khud ko delete na kare
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(context, id),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}