import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/lead_model.dart';
import '../core/constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // --- Date Parsing Helper ---
  DateTime? _parseDate(String dateStr) {
    try {
      // Try parsing "dd/MM/yyyy, hh:mm a" (Created Date / Call Date)
      return DateFormat('dd/MM/yyyy, hh:mm a').parse(dateStr);
    } catch (e) {
      try {
        // Try parsing "d/M/yyyy" (Payment Date)
        return DateFormat('d/M/yyyy').parse(dateStr);
      } catch (e2) {
        return null;
      }
    }
  }

  // --- Logic to Merge All Data ---
  List<Map<String, dynamic>> _getAllHistory(List<Lead> leads) {
    List<Map<String, dynamic>> history = [];

    for (var lead in leads) {
      // 1. Client Creation Event
      final createdDate = _parseDate(lead.dateTime);
      if (createdDate != null) {
        history.add({
          'type': 'new_client',
          'title': 'New Client Added',
          'subtitle': '${lead.leadName} (${lead.company})',
          'amount': '',
          'date': createdDate,
          'displayDate': lead.dateTime,
        });
      }

      // 2. Payments Events
      for (var p in lead.payments) {
        final pDate = _parseDate(p['date'].toString());
        if (pDate != null) {
          history.add({
            'type': 'payment',
            'title': 'Payment Received',
            'subtitle': 'From: ${lead.leadName}',
            'amount': '₹${(p['amount'] as num).toDouble().toStringAsFixed(0)}',
            'date': pDate,
            'displayDate': p['date'].toString(),
          });
        }
      }

      // 3. Call Logs Events
      for (var c in lead.callLogs) {
        final cDate = _parseDate(c['ts']!);
        if (cDate != null) {
          history.add({
            'type': 'call',
            'title': 'Call / Interaction',
            'subtitle': 'With: ${lead.leadName}',
            'amount': '',
            'date': cDate,
            'displayDate': c['ts']!,
          });
        }
      }
    }

    // Sort by Date (Newest First)
    history.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Activity History"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('leads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No history found"));
          }

          final leads = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Lead.fromJson(data);
          }).toList();

          final historyList = _getAllHistory(leads);

          if (historyList.isEmpty) {
            return const Center(child: Text("No activities yet"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: historyList.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final item = historyList[i];
              return _buildHistoryCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    IconData icon;
    Color color;

    switch (item['type']) {
      case 'payment':
        icon = Icons.attach_money;
        color = Colors.green;
        break;
      case 'new_client':
        icon = Icons.person_add_alt_1;
        color = Colors.blue;
        break;
      default:
        icon = Icons.phone_callback;
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['title'], style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                    Text(item['displayDate'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['subtitle'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    if (item['amount'] != '')
                      Text(item['amount'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}