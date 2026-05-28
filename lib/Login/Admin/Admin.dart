import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_constants.dart';
import 'package:lightatech/Features/Dashboard/screens/sidebar_menu.dart';
import 'package:lightatech/Features/Dashboard/widgets/dashboard_appbar.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final TextEditingController searchController = TextEditingController();

  Future<void> approve(String docID) async {
    await FirebaseFirestore.instance
        .collection('Approvals')
        .doc(docID)
        .update({'Status': "Approved"});
  }

  Future<void> reject(String docID) async {
    await FirebaseFirestore.instance
        .collection('Approvals')
        .doc(docID)
        .update({'Status': 'Rejected'});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: searchController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: "Search pending requests...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                searchController.clear();
                setState(() {});
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      drawer: const SidebarMenu(),

      appBar: DashboardAppBar(
        showBack: false,
        department: 'Admin',
        onBack: () {},
        searchController: searchController,
        onSearchChanged: (value) {
          setState(() {});
        },
      ),

      body: Stack(
        children: [
          Column(
            children: [


              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Approvals')
                      .where('Status', isEqualTo: 'Pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final approvals = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final searchableText = [
                        data['Email'],
                        data['RequestedDepartments'],
                        data['Status'],
                        doc.id,
                      ].join(' ').toLowerCase();

                      if (query.isEmpty) return true;

                      return searchableText.contains(query);
                    }).toList();

                    if (approvals.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Matching Requests",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 90),
                      itemCount: approvals.length,
                      itemBuilder: (context, index) {
                        final data =
                        approvals[index].data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber.shade100,
                              child: const Icon(
                                Icons.person,
                                color: Colors.amber,
                              ),
                            ),
                            title: Text(
                              data['Email'] ?? "Unknown",
                              style:
                              const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              "Requested: ${data['RequestedDepartments'] ?? '-'}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () => approve(approvals[index].id),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                  child: const Text("Approve"),
                                ),
                                TextButton(
                                  onPressed: () => reject(approvals[index].id),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text("Reject"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                GoRouter.of(context).pushNamed(AppRoutesName.JobForm);
              },
              backgroundColor: const Color(0xFFF8D94B),
              child: const Icon(Icons.add, color: Color(0xff46000A)),
            ),
          ),
        ],
      ),
    );
  }
}