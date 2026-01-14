import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_constants.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}


class _AdminState extends State<Admin> {
  Future<void> approve(String docID) async{
  await FirebaseFirestore.instance.collection('Approvals').doc(docID).update({'Status': "Approved"});
  }
  Future<void> reject(String docID) async{
    await FirebaseFirestore.instance.collection('Approvals').doc(docID).update({'Status':'Rejected'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Stack(
        children: [
          // MAIN CONTENT
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Approvals')
                .where('Status', isEqualTo: 'Pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No Request Pending"));
              }

              final approvals = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), // leave space for button
                itemCount: approvals.length,
                itemBuilder: (context, index) {
                  final data = approvals[index].data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['Email'] ?? "Unknown"),
                    subtitle:
                    Text("Requested: ${data['RequestedDepartments'] ?? '-'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                            onPressed: () => approve(approvals[index].id),
                            child: Text("Approve")),
                        TextButton(
                            onPressed: () => reject(approvals[index].id),
                            child: Text("Reject")),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // FIXED ADD BUTTON
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                GoRouter.of(context).pushNamed(AppRoutesName.NewForm);
              },
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
    );

  }

}

