import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Role check ke liye

import '../models/lead_model.dart';
import '../core/constants.dart';
import 'lead_detail_screen.dart';
import 'payment_screen.dart';

class PaidScreen extends StatefulWidget {
  const PaidScreen({super.key});

  @override
  State<PaidScreen> createState() => _PaidScreenState();
}

class _PaidScreenState extends State<PaidScreen> {
  // --- UPDATED FILTERS LIST ---
  List<String> _filters = ['All', 'Overdue', 'This Week', 'Day After', 'Day Before', 'My Payments'];
  String _selectedFilter = 'All';

  bool _isGlobalExpanded = false;
  Key _listKey = UniqueKey();
  final CollectionReference _leadsRef = FirebaseFirestore.instance.collection('leads');

  // --- USER INFO FOR MY PAYMENTS ---
  String _userRole = 'Employee';
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if(mounted) {
      setState(() {
        _userRole = prefs.getString('userRole') ?? 'Employee';
        _userName = prefs.getString('userName') ?? 'User';
      });
    }
  }

  void _toggleGlobalExpand() {
    setState(() {
      _isGlobalExpanded = !_isGlobalExpanded;
      _listKey = UniqueKey();
    });
  }

  // --- SMART FILTER DIALOG ---
  void _showCustomFilterDialog(List<Lead> allLeads) {
    String selectedAttribute = 'Company';
    String? selectedValue;

    final companies = allLeads.map((e) => e.company ?? 'Unknown').toSet().toList();
    final statuses = allLeads.map((e) => e.leadStatus).toSet().toList();
    final cities = allLeads.map((e) => e.address ?? 'Unknown').toSet().toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            List<String> dropdownOptions = [];
            if (selectedAttribute == 'Company') dropdownOptions = companies;
            if (selectedAttribute == 'Status') dropdownOptions = statuses;
            if (selectedAttribute == 'Address') dropdownOptions = cities;

            dropdownOptions.sort();

            return AlertDialog(
              title: const Text("Create Custom Filter"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedAttribute,
                    decoration: const InputDecoration(labelText: "Filter By Column", border: OutlineInputBorder()),
                    items: ['Company', 'Status', 'Address'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedAttribute = val!;
                        selectedValue = null;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedValue,
                    decoration: InputDecoration(labelText: "Select $selectedAttribute", border: const OutlineInputBorder()),
                    hint: const Text("Choose..."),
                    items: dropdownOptions.map((e) => DropdownMenuItem(value: e, child: Text(e.length > 20 ? "${e.substring(0,20)}..." : e))).toList(),
                    onChanged: (val) => setDialogState(() => selectedValue = val),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    if (selectedValue != null) {
                      String newFilter = "$selectedAttribute: $selectedValue";
                      setState(() {
                        if (!_filters.contains(newFilter)) _filters.add(newFilter);
                        _selectedFilter = newFilter;
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryYellow, foregroundColor: Colors.black),
                  child: const Text("Add Filter"),
                ),
              ],
            );
          }
      ),
    );
  }

  // --- ADD PAYMENT DIALOG ---
  void _showAddPaymentDialog() {
    String? selectedClientId;
    Lead? selectedLead;
    DateTime selectedDate = DateTime.now();
    TextEditingController dateCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Record Payment"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _leadsRef.orderBy('leadName').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      final clients = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        data['id'] = doc.id;
                        return Lead.fromJson(data);
                      }).toList();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text("Select Client Name"),
                            value: selectedClientId,
                            isExpanded: true,
                            items: clients.map((lead) => DropdownMenuItem(value: lead.id, onTap: () => selectedLead = lead, child: Text(lead.leadName ?? 'Unknown'))).toList(),
                            onChanged: (val) => setDialogState(() => selectedClientId = val),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: dateCtrl, readOnly: true,
                    decoration: const InputDecoration(labelText: "Select Date", prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) { selectedDate = picked; dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked); }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(onPressed: () { if (selectedLead != null) { Navigator.pop(context); _openPaymentScreen(selectedLead!); }}, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryYellow, foregroundColor: Colors.black), child: const Text("Next")),
              ],
            );
          }
      ),
    );
  }

  void _openPaymentScreen(Lead lead) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => PaymentFormScreen(receiptNo: null, grandTotal: lead.finalAmount, totalPaidSoFar: lead.totalPaid)),
    );
    if (result != null && result['action'] == 'add') {
      final amt = (result['amount'] as num?)?.toDouble() ?? 0.0;
      final paymentEntry = {'amount': amt, 'date': result['date'], 'remark': result['remark'], 'receiptNo': result['receiptNo']};
      final updatedPayments = [paymentEntry, ...lead.payments];
      final newTotalPaid = updatedPayments.fold(0.0, (p, e) => p + (e['amount'] as num).toDouble());
      final newPending = (lead.finalAmount - newTotalPaid).clamp(0.0, double.infinity);
      String newStatus = lead.leadStatus;
      if (newTotalPaid >= lead.finalAmount && lead.finalAmount > 0) newStatus = 'Paid';
      await _leadsRef.doc(lead.id).update({'payments': updatedPayments, 'totalPaid': newTotalPaid, 'pendingAmount': newPending, 'leadStatus': newStatus});
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Recorded!')));
    }
  }

  Future<void> _recordCallAndLaunch(Lead lead, String? phone) async {
    final uri = PhoneHelper.telUri(phone);
    if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // --- GROUPING LOGIC ---
  Map<String, List<Lead>> _groupLeadsByCompany(List<Lead> leads) {
    Map<String, List<Lead>> grouped = {};
    for (var lead in leads) {
      String company = (lead.company == null || lead.company!.trim().isEmpty) ? 'Individuals / Others' : lead.company!;
      if (!grouped.containsKey(company)) { grouped[company] = []; }
      grouped[company]!.add(lead);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentDialog,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Record Payment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _leadsRef.orderBy('dateTime', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData) return const Center(child: Text("No Data"));

          final allLeads = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Lead.fromJson(data);
          }).toList();

          // Apply Filters
          List<Lead> displayedLeads = [];

          if (_selectedFilter == 'My Payments') {
            // Special handling for My Payments will be done in the rendering part
            displayedLeads = allLeads;
          } else if (_selectedFilter == 'All') {
            displayedLeads = allLeads;
          } else if (_selectedFilter == 'Overdue') {
            displayedLeads = allLeads.where((l) => l.pendingAmount > 0).toList();
          } else if (_selectedFilter == 'This Week') {
            final now = DateTime.now();
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            // Assuming simplified check for demo
            displayedLeads = allLeads;
          }
          // --- NEW: DAY AFTER & DAY BEFORE FILTERS ---
          else if (_selectedFilter == 'Day After') {
            final tomorrow = DateTime.now().add(const Duration(days: 1));
            final dateStr = DateFormat('dd/MM/yyyy').format(tomorrow);
            displayedLeads = allLeads.where((l) => l.dateTime.contains(dateStr)).toList();
          } else if (_selectedFilter == 'Day Before') {
            final yesterday = DateTime.now().subtract(const Duration(days: 1));
            final dateStr = DateFormat('dd/MM/yyyy').format(yesterday);
            displayedLeads = allLeads.where((l) => l.dateTime.contains(dateStr)).toList();
          } else {
            final parts = _selectedFilter.split(': ');
            if (parts.length == 2) {
              final key = parts[0];
              final val = parts[1];
              if (key == 'Company') displayedLeads = allLeads.where((l) => l.company == val).toList();
              if (key == 'Status') displayedLeads = allLeads.where((l) => l.leadStatus == val).toList();
              if (key == 'Address') displayedLeads = allLeads.where((l) => l.address == val).toList();
            }
          }

          // --- RENDERING LOGIC ---
          if (_selectedFilter == 'My Payments') {
            return _buildMyPaymentsView(allLeads);
          }

          // Default View (Grouped by Company)
          final groupedLeads = _groupLeadsByCompany(displayedLeads);
          final sortedCompanyNames = groupedLeads.keys.toList()..sort();

          return Column(
            children: [
              _buildFilterHeader(allLeads),
              Expanded(
                child: displayedLeads.isEmpty
                    ? const Center(child: Text("No clients match this filter"))
                    : ListView.builder(
                  key: _listKey,
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedCompanyNames.length,
                  itemBuilder: (ctx, i) {
                    final companyName = sortedCompanyNames[i];
                    final companyLeads = groupedLeads[companyName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 10, top: 10),
                          child: Row(
                            children: [
                              Container(width: 4, height: 18, color: kPrimaryYellow, margin: const EdgeInsets.only(right: 8)),
                              Text(companyName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey, letterSpacing: 1)),
                              const SizedBox(width: 8),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: Text("${companyLeads.length}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),
                        ...companyLeads.map((lead) => _buildPaymentCard(lead)).toList(),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- MY PAYMENTS VIEW (NEW FEATURE) ---
  Widget _buildMyPaymentsView(List<Lead> allLeads) {
    List<Lead> targetLeads;

    // 1. Filter Data based on Role
    if (_userRole == 'Admin') {
      targetLeads = allLeads; // Admin sees everyone's entries
    } else {
      // Employee sees ONLY their entries
      targetLeads = allLeads.where((l) => l.createdBy == _userName).toList();
    }

    if (targetLeads.isEmpty) {
      return Column(children: [_buildFilterHeader(allLeads), const Expanded(child: Center(child: Text("No payment entries found")))]);
    }

    // 2. Group by Employee Name
    Map<String, List<Lead>> groupedByEmployee = {};
    for (var lead in targetLeads) {
      String key = lead.createdBy ?? 'Unknown Staff';
      if (!groupedByEmployee.containsKey(key)) groupedByEmployee[key] = [];
      groupedByEmployee[key]!.add(lead);
    }

    return Column(
      children: [
        _buildFilterHeader(allLeads),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: groupedByEmployee.entries.map((entry) {
              final empName = entry.key;
              final leads = entry.value;

              // Calculate Totals
              double totalCollected = 0;
              for(var l in leads) { totalCollected += l.totalPaid; }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  initiallyExpanded: _userRole != 'Admin', // Auto open for employee, collapse for admin
                  leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text(avatarChar(empName), style: const TextStyle(fontWeight: FontWeight.bold))),
                  title: Text(empName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${leads.length} Clients • Collected: ₹${totalCollected.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                  children: leads.map((lead) => _buildPaymentCard(lead)).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- HEADER WIDGET (Refactored to avoid duplication) ---
  Widget _buildFilterHeader(List<Lead> allLeads) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 2))
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Payment Manager", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                IconButton(
                  onPressed: _toggleGlobalExpand,
                  icon: Icon(_isGlobalExpanded ? Icons.unfold_less : Icons.unfold_more, color: Colors.black87),
                  tooltip: "Toggle Details",
                  style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ..._filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  // These filters cannot be deleted
                  final isDefault = (filter == 'All' || filter == 'Overdue' || filter == 'This Week' || filter == 'Day After' || filter == 'Day Before' || filter == 'My Payments');

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InputChip(
                      showCheckmark: false,
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade300, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      onPressed: () => setState(() => _selectedFilter = filter),
                      onDeleted: isDefault ? null : () {
                        setState(() {
                          _filters.remove(filter);
                          _selectedFilter = 'All';
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  );
                }),
                InkWell(
                  onTap: () => _showCustomFilterDialog(allLeads),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: kPrimaryYellow, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Lead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 10, right: 10), // Added slight margin for nested view
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isGlobalExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: lead.pendingAmount > 0 ? Colors.red[50] : Colors.green[50],
            child: Icon(
              lead.pendingAmount > 0 ? Icons.priority_high : Icons.check,
              color: lead.pendingAmount > 0 ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          title: Text(lead.leadName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text("Pending: ₹${lead.pendingAmount.toStringAsFixed(0)}", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(onTap: () => _recordCallAndLaunch(lead, lead.whatsapp), child: const CircleAvatar(radius: 16, backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.call, size: 16, color: Colors.blue))),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("LAST 3 PAYMENTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  if (lead.payments.isEmpty) const Text("No payments yet.", style: TextStyle(color: Colors.grey, fontSize: 12)) else ...lead.payments.take(3).map((p) => Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(6)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(p['date'] ?? '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)), Text("₹${(p['amount'] as num).toDouble().toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]))),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeadDetailScreen(lead: lead))), style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("View Full Profile", style: TextStyle(color: Colors.black87)))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}