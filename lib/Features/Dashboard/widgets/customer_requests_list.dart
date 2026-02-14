import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerRequestsList extends StatefulWidget {
  final String searchText;

  const CustomerRequestsList({
    super.key,
    required this.searchText,
  });

  @override
  State<CustomerRequestsList> createState() => _CustomerRequestsListState();
}

class _CustomerRequestsListState extends State<CustomerRequestsList> {
  Stream<QuerySnapshot>? _customerRequestsStream;

  @override
  void initState() {
    super.initState();
    _customerRequestsStream = FirebaseFirestore.instance
        .collection("customers")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _customerRequestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No customer requests available"));
        }

        final query = widget.searchText.trim().toLowerCase();

        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final name = (data["name"] ?? "").toString().toLowerCase();
          final partyName = (data["partyName"] ?? "").toString().toLowerCase();
          final particularJobName = (data["particularJobName"] ?? "").toString().toLowerCase();

          if (query.isEmpty) return true;
          return name.contains(query) || partyName.contains(query) || particularJobName.contains(query);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text("No matching requests"));
        }

        return Container(
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data() as Map<String, dynamic>;
              final docId = filteredDocs[index].id;

              final name = data["name"] ?? "No Name";
              final partyName = data["partyName"] ?? "No Party";
              final particularJobName = data["particularJobName"] ?? "No Job";
              final priority = data["priority"] ?? "Normal";
              final deliveryAt = data["deliveryAt"] ?? "Not specified";
              final createdAt = data["createdAt"];

              // Format date
              String formattedDate = "N/A";
              if (createdAt != null) {
                final dateTime = (createdAt as Timestamp).toDate();
                formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () {
                    context.push('/customer-request-detail/$docId');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOP ROW: Icon + Name + Priority Badge
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    partyName.toString(),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Priority Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(priority).withOpacity(0.2),
                                border: Border.all(
                                  color: _getPriorityColor(priority),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                priority.toString(),
                                style: TextStyle(
                                  color: _getPriorityColor(priority),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // BOTTOM ROW: Job Name + Delivery Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Job: ${particularJobName.toString()}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Delivery: $deliveryAt",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}