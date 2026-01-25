import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActivityListFirestore extends StatefulWidget {
  final String searchText;
  final String department;

  const ActivityListFirestore({
    super.key,
    required this.searchText,
    required this.department,
  });

  @override
  State<ActivityListFirestore> createState() =>
      _ActivityListFirestoreState();
}

class _ActivityListFirestoreState extends State<ActivityListFirestore> {
  late final Stream<QuerySnapshot> _jobsStream;

  @override
  void initState() {
    super.initState();

    // 🔥 Firestore stream (NO orderBy → web safe)
    _jobsStream = FirebaseFirestore.instance
        .collection("jobs")
        .where("currentDepartment", isEqualTo: widget.department)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _jobsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading activities"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No entries available"));
        }

        final search = widget.searchText.trim().toLowerCase();

        // 🔥 Filter safely from nested designer.data
        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final designerData =
          data["designer"]?["data"] as Map<String, dynamic>?;

          final partyName =
          (designerData?["PartyName"] ?? "").toString().toLowerCase();

          final particularJob =
          (designerData?["ParticularJobName"] ?? "")
              .toString()
              .toLowerCase();

          if (search.isEmpty) return true;

          return partyName.contains(search) ||
              particularJob.contains(search);
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text("No matching entries"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final designerData =
            data["designer"]?["data"] as Map<String, dynamic>?;

            final partyName =
            (designerData?["PartyName"] ?? "No Party Name").toString();

            final particularJob =
            (designerData?["ParticularJobName"] ??
                "No Particular Job")
                .toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.push(
                    '/jobform',
                    extra: {
                      'department': widget.department,
                      'lpm': doc.id, // 🔥 job ID
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          Icons.work_outline,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              particularJob,
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
