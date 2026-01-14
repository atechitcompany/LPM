import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';
import '../core/constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Default selection
  String _selectedCompany = sampleCompanies.first;
  String _timeFilter = 'Monthly'; // Options: Daily, Monthly, Yearly

  // Firestore reference
  final CollectionReference _leadsRef = FirebaseFirestore.instance.collection('leads');

  // --- Date Helpers ---
  String _getTodayStr() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _getMonthStr() {
    final now = DateTime.now();
    return '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _getYearStr() {
    final now = DateTime.now();
    return '${now.year}';
  }

  // --- Logic to Calculate Totals ---
  Map<String, dynamic> _calculateStats(List<Lead> allLeads) {
    double totalPending = 0.0;
    double periodCollection = 0.0;
    List<Map<String, dynamic>> clientBreakdown = [];

    // Filter leads by selected company
    final companyLeads = allLeads.where((l) => l.company == _selectedCompany).toList();

    for (var lead in companyLeads) {
      // 1. Calculate Total Pending for this company
      totalPending += lead.pendingAmount;

      // 2. Calculate Collection based on Time Filter
      double collectedFromLeadInPeriod = 0.0;

      for (var payment in lead.payments) {
        final pDate = payment['date'] as String; // Format: dd/MM/yyyy
        final pAmount = (payment['amount'] as num).toDouble();

        bool isMatch = false;

        if (_timeFilter == 'Daily') {
          if (pDate == _getTodayStr()) isMatch = true;
        } else if (_timeFilter == 'Monthly') {
          // Check if "MM/yyyy" matches
          if (pDate.endsWith(_getMonthStr())) isMatch = true;
        } else if (_timeFilter == 'Yearly') {
          // Check if "yyyy" matches
          if (pDate.endsWith(_getYearStr())) isMatch = true;
        }

        if (isMatch) {
          periodCollection += pAmount;
          collectedFromLeadInPeriod += pAmount;
        }
      }

      // Add to breakdown list if they have pending OR paid something in this period
      if (lead.pendingAmount > 0 || collectedFromLeadInPeriod > 0) {
        clientBreakdown.add({
          'name': lead.leadName,
          'pending': lead.pendingAmount,
          'paidInPeriod': collectedFromLeadInPeriod,
          'status': lead.leadStatus,
        });
      }
    }

    // Sort list: High pending first
    clientBreakdown.sort((a, b) => (b['pending'] as double).compareTo(a['pending'] as double));

    return {
      'totalPending': totalPending,
      'periodCollection': periodCollection,
      'breakdown': clientBreakdown,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Business Reports"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          // --- TOP CONTROLS (Company & Time) ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Company Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCompany,
                  decoration: InputDecoration(
                    labelText: 'Select Company',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: sampleCompanies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCompany = v);
                  },
                ),
                const SizedBox(height: 12),
                // Time Filter Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: ['Daily', 'Monthly', 'Yearly'].map((filter) {
                      final isSelected = _timeFilter == filter;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _timeFilter = filter),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              filter,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN CONTENT (StreamBuilder) ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _leadsRef.snapshots(), // Listening to all leads
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                // Convert Firebase data to Lead objects
                final leads = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  return Lead.fromJson(data);
                }).toList();

                // Calculate Stats
                final stats = _calculateStats(leads);
                final breakdown = stats['breakdown'] as List<Map<String, dynamic>>;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- SUMMARY CARDS ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: '$_timeFilter Collection',
                              amount: stats['periodCollection'],
                              color: Colors.green,
                              icon: Icons.attach_money,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Total Pending',
                              amount: stats['totalPending'],
                              color: Colors.redAccent,
                              icon: Icons.warning_amber_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Text(
                        "Client Breakdown ($_selectedCompany)",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // --- CLIENT LIST ---
                      if (breakdown.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: Text("No data for this criteria.")),
                        )
                      else
                        ...breakdown.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(item['status'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (item['paidInPeriod'] > 0)
                                      Text(
                                        '+ ₹${(item['paidInPeriod'] as double).toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                      ),
                                    Text(
                                      'Pending: ₹${(item['pending'] as double).toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required double amount, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
    );
  }
}