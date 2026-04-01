import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_user_screen.dart';

class AdminUserListScreen extends StatefulWidget {
  final String type;

  const AdminUserListScreen({super.key, required this.type});

  @override
  State<AdminUserListScreen> createState() =>
      _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {

  final searchController = TextEditingController();

  Stream<List<Map<String, dynamic>>> fetchUsers() {
    if (widget.type == "Staff") {
      return FirebaseFirestore.instance
          .collection('Staff')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "name": doc['Name'],
            "email": doc['Email'],
            "type": "Staff",
            "role": doc['Role'],
          };
        }).toList();
      });
    } else {
      return FirebaseFirestore.instance
          .collection('customers')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "name": doc['Username'],
            "email": doc['Email'],
            "type": "Customer",
            "role": "-",
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchText = searchController.text.toLowerCase();


    return Scaffold(
    backgroundColor: const Color(0xFFEEF2FF),

    appBar: AppBar(
    title: Text("${widget.type} Users"),
    backgroundColor: const Color(0xFFEEF2FF),
    elevation: 0,
    ),

    body: Column(
    children: [

    /// 🔍 SEARCH BAR (REAL WORKING)
    Padding(
    padding: const EdgeInsets.all(12),
    child: Container(
    height: 44,
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
    ),
    ),
    ),
    ),

    /// 📋 USER LIST
    Expanded(
    child: StreamBuilder<List<Map<String, dynamic>>>(
    stream: fetchUsers(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
    }

    /// 🔥 APPLY SEARCH FILTER HERE
    final users = snapshot.data!
        .where((user) => user['name']
        .toLowerCase()
        .contains(searchText))
        .toList();

    if (users.isEmpty) {
    return const Center(child: Text("No users found"));
    }

    return ListView.builder(
    itemCount: users.length,
    itemBuilder: (context, index) {
    final user = users[index];

    return Container(
    margin: const EdgeInsets.symmetric(
    horizontal: 12, vertical: 6),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
    children: [

    /// 👤 Avatar
    CircleAvatar(
    radius: 22,
    backgroundColor: Colors.grey.shade200,
    child: Text(
    user['name'][0].toUpperCase(),
    ),
    ),

    const SizedBox(width: 12),

    /// 📝 Name + Email
    Expanded(
    child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
    Text(
    user['name'],
    style: const TextStyle(
    fontWeight: FontWeight.w600,
    ),
    ),
    Text(
    user['email'],
    style: TextStyle(
    color: Colors.grey.shade600,
    fontSize: 12,
    ),
    ),
    ],
    ),
    ),

    /// ✏️ EDIT
    GestureDetector(
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) =>
    EditUserScreen(user: user),
    ),
    );
    },
    child: const CircleAvatar(
    radius: 16,
    backgroundColor: Colors.blue,
    child: Icon(Icons.edit,
    color: Colors.white, size: 16),
    ),
    ),

    const SizedBox(width: 6),

    /// 🗑 DELETE
    GestureDetector(
    onTap: () async {
    final collection =
    user['type'] == "Staff"
    ? "Staff"
        : "customers";

    await FirebaseFirestore.instance
        .collection(collection)
        .doc(user['id'])
        .delete();

    ScaffoldMessenger.of(context)
        .showSnackBar(
    const SnackBar(
    content: Text("User Deleted")),
    );
    },
    child: const CircleAvatar(
    radius: 16,
    backgroundColor: Colors.red,
    child: Icon(Icons.delete,
    color: Colors.white, size: 16),
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
