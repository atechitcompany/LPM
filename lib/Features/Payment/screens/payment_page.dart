import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../viewmodels/payment_viewmodel.dart';
import '../widgets/record_payment_button.dart';
import 'record_payment_page.dart';
import 'package:lightatech/Features/Dashboard/screens/sidebar_menu.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentViewModel _viewModel = PaymentViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Payment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payments")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No payments recorded yet.", style: TextStyle(fontSize: 16)));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              final grandTotal = (data["grandTotal"] ?? 0.0) as num;
              final client = data["client"] ?? "";
              final job = data["job"] ?? "";
              final gstType = data["gstType"] ?? "No GST";
              final createdAt = data["createdAt"] as Timestamp?;
              final dateStr = createdAt != null
                  ? DateFormat('dd/MM/yyyy').format(createdAt.toDate())
                  : "—";
              final installments = (data["installments"] as List<dynamic>?) ?? [];
              final paidCount = installments.where((e) => e["status"] == "Yes").length;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(docId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo)),
                        Text(dateStr, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(client, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(job, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("GST: $gstType", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        Text("₹ ${grandTotal.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    if (installments.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text("Installments: $paidCount/${installments.length} paid",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: RecordPaymentButton(onTap: () => context.push('/record-payment')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}