import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  // --- APPROVE LOGIC ---
  void _approveRequest(BuildContext context, String reqId, Map<String, dynamic> reqData) async {
    try {
      final userId = reqData['userId'];
      final type = reqData['type']; // Column or Tab
      final permission = reqData['permission']; // View or Edit
      final item = reqData['item']; // e.g. Amount

      // 1. Update User Permissions in 'users' collection
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      if (type == 'Tab Access') {
        await userRef.update({
          'visibleTabs': FieldValue.arrayUnion([item])
        });
      } else {
        // Column Access
        if (permission == 'View') {
          await userRef.update({
            'visibleColumns': FieldValue.arrayUnion([item])
          });
        } else {
          // Edit means View + Edit both
          await userRef.update({
            'visibleColumns': FieldValue.arrayUnion([item]),
            'editableColumns': FieldValue.arrayUnion([item])
          });
        }
      }

      // 2. Mark Request as Approved
      await FirebaseFirestore.instance.collection('access_requests').doc(reqId).update({'status': 'Approved'});

      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permission Granted!"), backgroundColor: Colors.green));
      }

    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _rejectRequest(String reqId) {
    FirebaseFirestore.instance.collection('access_requests').doc(reqId).update({'status': 'Rejected'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Access Requests")),
      body: StreamBuilder<QuerySnapshot>(
        // FIX: orderBy hata diya hai (Indexing issue avoid karne ke liye)
        stream: FirebaseFirestore.instance
            .collection('access_requests')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading requests: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Pending Requests"));
          }

          // FIX: Manual Sorting in App (Dart Code) instead of Firebase
          var reqs = snapshot.data!.docs.toList();
          reqs.sort((a, b) {
            // Sort by Time (Descending)
            Timestamp t1 = (a.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
            Timestamp t2 = (b.data() as Map<String, dynamic>)['timestamp'] ?? Timestamp.now();
            return t2.compareTo(t1);
          });

          return ListView.builder(
            itemCount: reqs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (ctx, i) {
              final req = reqs[i];
              final data = req.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data['userName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                            child: Text(data['type'] ?? '-', style: TextStyle(fontSize: 10, color: Colors.blue[800], fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // RichText for better reading
                      RichText(
                        text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 15),
                            children: [
                              const TextSpan(text: "Asking to "),
                              TextSpan(text: "${data['permission']} ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                              const TextSpan(text: "the "),
                              TextSpan(text: "${data['item']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ]
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => _rejectRequest(req.id),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                            child: const Text("Reject"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () => _approveRequest(context, req.id, data),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text("Approve"),
                          ),
                        ],
                      )
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