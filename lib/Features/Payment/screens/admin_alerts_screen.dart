import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAlertsScreen extends StatelessWidget {
  const AdminAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Activity & Alerts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              // Saare purane alerts delete karne ka button
              final batch = FirebaseFirestore.instance.batch();
              var snapshots = await FirebaseFirestore.instance.collection('admin_notifications').get();
              for (var doc in snapshots.docs) {
                batch.delete(doc.reference);
              }
              await batch.commit();
            },
            tooltip: "Clear All",
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admin_notifications')
            .orderBy('timestamp', descending: true)
            .limit(50) // Sirf last 50 activities dikhayega
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No new activities", style: TextStyle(color: Colors.grey)));
          }

          final alerts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: alerts.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (ctx, i) {
              final data = alerts[i].data() as Map<String, dynamic>;
              final type = data['type'] ?? 'Info';

              // Icon Colors
              IconData icon = Icons.notifications;
              Color color = Colors.grey;
              if (type == 'Payment') { icon = Icons.attach_money; color = Colors.green; }
              if (type == 'New Lead') { icon = Icons.person_add; color = Colors.blue; }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(data['title'] ?? 'Alert', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['message'] ?? ''),
                      const SizedBox(height: 4),
                      Text("${data['date']} • By ${data['byUser']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
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