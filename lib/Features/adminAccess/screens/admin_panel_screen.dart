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
  final searchController = TextEditingController();

  /// 🔥 REALTIME STREAM (FIXED)
  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    final staffStream =
    FirebaseFirestore.instance.collection('Staff').snapshots();


    final customerStream =
    FirebaseFirestore.instance.collection('customers').snapshots();

    return staffStream.asyncMap((staffSnap) async {
    final customerSnap = await FirebaseFirestore.instance
        .collection('customers')
        .get();

    List<Map<String, dynamic>> users = [];

    /// STAFF
    for (var doc in staffSnap.docs) {
    users.add({
    "id": doc.id,
    "name": doc['Name'],
    "email": doc['Email'],
    "type": "Staff",
    });
    }

    /// CUSTOMER
    for (var doc in customerSnap.docs) {
    users.add({
    "id": doc.id,
    "name": doc['Username'],
    "email": doc['Email'],
    "type": "Customer",
    });
    }

    return users;
    });


  }

  @override
  Widget build(BuildContext context) {
    final searchText = searchController.text.toLowerCase();


    return Scaffold(
    backgroundColor: const Color(0xFFEEF2FF),

    appBar: AppBar(
    backgroundColor: const Color(0xFFEEF2FF),
    elevation: 0,
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

    /// 🔍 SEARCH BAR
    Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    child: Container(
    height: 44,
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    ),
    child: TextField(
    controller: searchController,
    onChanged: (_) => setState(() {}),
    decoration: const InputDecoration(
    hintText: 'Search users...',
    prefixIcon: Icon(Icons.search),
    border: InputBorder.none,
    ),
    ),
    ),
    ),

    /// 🔥 STREAM BUILDER (PERFORMANCE FIX)
    Expanded(
    child: StreamBuilder<List<Map<String, dynamic>>>(
    stream: getAllUsersStream(),
    builder: (context, snapshot) {

    if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
    }

    final allUsers = snapshot.data!;

    /// 🔥 SEARCH FILTER (OPTIMIZED)
    final filteredUsers = searchText.isEmpty
    ? []
        : allUsers
        .where((user) => user['name']
        .toLowerCase()
        .contains(searchText))
        .toList();

    /// 🔥 SHOW CARDS (NO SEARCH)
    if (searchText.isEmpty) {
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

    /// 🔥 NO RESULT
    if (filteredUsers.isEmpty) {
    return const Center(child: Text("No users found"));
    }

    /// 🔥 SEARCH RESULT UI (DASHBOARD STYLE)
    return ListView.builder(
    itemCount: filteredUsers.length,
    itemBuilder: (context, index) {
    final user = filteredUsers[index];

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

    /// 📝 Info
    Expanded(
    child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
    Text(
    user['name'],
    style: const TextStyle(
    fontWeight: FontWeight.w600),
    ),
    Text(
    user['email'],
    style: TextStyle(
    fontSize: 12,
    color: Colors.grey.shade600,
    ),
    ),
    ],
    ),
    ),

    /// 🟢 TYPE BADGE
    Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 10, vertical: 4),
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

  /// CARD
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
            Text(title),
          ],
        ),
      ),
    );
  }

  /// OPTIONS
  Widget _buildOptionsSheet(BuildContext context,
      {required String type}) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [


    ListTile(
    leading: const Icon(Icons.edit),
    title: const Text("Edit"),
    onTap: () {
    Navigator.pop(context);
    context.push('/admin-users?type=$type');
    },
    ),

    ListTile(
    leading: const Icon(Icons.add),
    title: const Text("Add New"),
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
    );


  }
}
