import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../widgets/record_payment_button.dart';
import 'package:lightatech/Features/Dashboard/screens/sidebar_menu.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedTab = 'All';
  String _searchQuery = '';
  final List<String> _tabs = ['All', 'Overdue', 'Jobs', 'Paid'];
  final TextEditingController _searchController = TextEditingController();

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;
    final client = (data['client'] ?? '').toString().toLowerCase();
    final lpm = (data['lpmNumber'] ?? '').toString().toLowerCase();
    return client.contains(_searchQuery) || lpm.contains(_searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Payment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.black), onPressed: () {}),
          IconButton(
            icon: Stack(children: [
              const Icon(Icons.notifications_outlined, color: Colors.black),
              Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
            ]),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search client or LPM number...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            ..._tabs.map((tab) {
                              final selected = _selectedTab == tab;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTab = tab),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: selected ? Colors.black : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: selected ? null : Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                      color: selected ? Colors.white : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
                        child: const Icon(Icons.add, size: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          final Map<String, Map<String, dynamic>> clientMap = {};
          final List<Map<String, dynamic>> allJobItems = [];
          final List<Map<String, dynamic>> paidItems = [];

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            final client = (data['client'] ?? '').toString();
            final installments = (data["installments"] as List<dynamic>?) ?? [];

            if (!clientMap.containsKey(client)) {
              clientMap[client] = {
                'client': client,
                'lpmNumber': (data['lpmNumber'] ?? '').toString(),
                'jobs': <Map<String, dynamic>>[],
              };
            }

            for (final inst in installments) {
              final ts = inst["date"] as Timestamp?;
              if (ts == null) continue;
              final instDate = DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day);
              final amount = (inst["amount"] ?? 0.0) as num;

              if (inst["status"] == "Yes") {
                paidItems.add({
                  'docId': docId,
                  'data': data,
                  'installment': inst,
                  'date': instDate,
                  'amount': amount,
                  'clientName': client,
                  'lpmNumber': (data['lpmNumber'] ?? '').toString(),
                });
                continue;
              }

              final jobEntry = {
                'docId': docId,
                'data': data,
                'installment': inst,
                'date': instDate,
                'amount': amount,
                'clientName': client,
                'lpmNumber': (data['lpmNumber'] ?? '').toString(),
              };
              (clientMap[client]!['jobs'] as List<Map<String, dynamic>>).add(jobEntry);
              allJobItems.add(jobEntry);
            }
          }

          bool _matchesItem(Map<String, dynamic> item) {
            if (_searchQuery.isEmpty) return true;
            final client = (item['clientName'] ?? '').toString().toLowerCase();
            final lpm = (item['lpmNumber'] ?? '').toString().toLowerCase();
            return client.contains(_searchQuery) || lpm.contains(_searchQuery);
          }

          if (_selectedTab == 'Paid') {
            final filtered = paidItems.where(_matchesItem).toList();
            if (filtered.isEmpty) {
              return const Center(child: Text("No paid payments found.", style: TextStyle(fontSize: 16)));
            }
            return _PaidTabView(paidItems: filtered);
          }

          if (_selectedTab == 'Jobs') {
            allJobItems.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
            final filtered = allJobItems.where(_matchesItem).toList();
            if (filtered.isEmpty) {
              return const Center(child: Text("No jobs found.", style: TextStyle(fontSize: 16)));
            }
            return _JobsTabView(jobItems: filtered, todayDate: todayDate);
          }

          final List<Map<String, dynamic>> allClients = [];

          for (final entry in clientMap.entries) {
            final jobs = entry.value['jobs'] as List<Map<String, dynamic>>;
            if (jobs.isEmpty) continue;

            final lpm = (entry.value['lpmNumber'] ?? '').toString().toLowerCase();
            if (_searchQuery.isNotEmpty &&
                !entry.key.toLowerCase().contains(_searchQuery) &&
                !lpm.contains(_searchQuery)) continue;

            final todayJobs = jobs.where((j) => (j['date'] as DateTime) == todayDate).toList();
            final overdueJobs = jobs.where((j) => (j['date'] as DateTime).isBefore(todayDate)).toList();
            final upcomingJobs = jobs.where((j) => (j['date'] as DateTime).isAfter(todayDate)).toList();

            final totalPending = jobs.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());
            final overdueTotal = overdueJobs.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());

            allClients.add({
              'client': entry.key,
              'lpmNumber': entry.value['lpmNumber'],
              'jobs': jobs,
              'todayJobs': todayJobs,
              'overdueJobs': overdueJobs,
              'upcomingJobs': upcomingJobs,
              'totalPending': totalPending,
              'overdueTotal': overdueTotal,
              'hasOverdue': overdueJobs.isNotEmpty,
            });
          }

          List<Map<String, dynamic>> displayList;
          if (_selectedTab == 'Overdue') {
            displayList = allClients.where((c) => (c['overdueJobs'] as List).isNotEmpty).toList();
          } else {
            displayList = allClients;
          }

          if (displayList.isEmpty) {
            return Center(child: Text("No ${_selectedTab == 'Overdue' ? 'overdue' : ''} payments.", style: const TextStyle(fontSize: 16)));
          }

          if (_selectedTab == 'All') {
            return _AllTabView(displayList: displayList, todayDate: todayDate, selectedTab: _selectedTab);
          }

          return _OverdueTabView(displayList: displayList);
        },
      ),
      floatingActionButton: RecordPaymentButton(onTap: () => context.push('/record-payment')),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _PaidTabView extends StatelessWidget {
  final List<Map<String, dynamic>> paidItems;
  const _PaidTabView({required this.paidItems});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,##0', 'en_IN');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paidItems.length,
      itemBuilder: (context, index) {
        final item = paidItems[index];
        final client = item['clientName'] as String;
        final data = item['data'] as Map<String, dynamic>;
        final inst = item['installment'] as Map<String, dynamic>;
        final date = item['date'] as DateTime;
        final amount = (item['amount'] as num).toDouble();
        final jobName = inst['label'] ?? data['jobName'] ?? data['job'] ?? 'Job';
        final lpm = (item['lpmNumber'] ?? '').toString();

        return GestureDetector(
          onTap: () => context.push('/client-detail', extra: {'client': client}),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Icon(Icons.check, size: 18, color: Colors.green)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(jobName.toString(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (lpm.isNotEmpty)
                        Text('LPM: $lpm', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: const Text('Paid', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd/MM/yyyy').format(date), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text('₹${fmt.format(amount.toInt())}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JobsTabView extends StatelessWidget {
  final List<Map<String, dynamic>> jobItems;
  final DateTime todayDate;
  const _JobsTabView({required this.jobItems, required this.todayDate});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,##0', 'en_IN');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobItems.length,
      itemBuilder: (context, index) {
        final job = jobItems[index];
        final client = job['clientName'] as String;
        final data = job['data'] as Map<String, dynamic>;
        final inst = job['installment'] as Map<String, dynamic>;
        final date = job['date'] as DateTime;
        final amount = (job['amount'] as num).toDouble();
        final jobName = inst['label'] ?? data['jobName'] ?? data['job'] ?? 'Job';
        final lpm = (job['lpmNumber'] ?? '').toString();
        final isOverdue = date.isBefore(todayDate);
        final isToday = date == todayDate;

        return GestureDetector(
          onTap: () => context.push('/client-detail', extra: {'client': client}),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(color: Colors.yellow.shade200, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('IMP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(jobName.toString(), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (lpm.isNotEmpty)
                        Text('LPM: $lpm', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(12)),
                        child: const Text('Today', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                      )
                    else if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Text('Overdue', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w600)),
                      )
                    else
                      Text(DateFormat('dd/MM/yyyy').format(date), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(height: 6),
                    Text('₹${fmt.format(amount.toInt())}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AllTabView extends StatefulWidget {
  final List<Map<String, dynamic>> displayList;
  final DateTime todayDate;
  final String selectedTab;
  const _AllTabView({required this.displayList, required this.todayDate, required this.selectedTab});

  @override
  State<_AllTabView> createState() => _AllTabViewState();
}

class _AllTabViewState extends State<_AllTabView> {
  bool _todayExpanded = true;
  bool _overdueExpanded = false;
  bool _upcomingExpanded = false;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> todayItems = [];
    final List<Map<String, dynamic>> overdueItems = [];
    final List<Map<String, dynamic>> upcomingItems = [];

    for (final c in widget.displayList) {
      final client = c['client'] as String;
      final lpm = (c['lpmNumber'] ?? '').toString();
      for (final j in (c['todayJobs'] as List<Map<String, dynamic>>)) {
        todayItems.add({...j, 'clientName': client, 'lpmNumber': lpm});
      }
      for (final j in (c['overdueJobs'] as List<Map<String, dynamic>>)) {
        overdueItems.add({...j, 'clientName': client, 'lpmNumber': lpm});
      }
      for (final j in (c['upcomingJobs'] as List<Map<String, dynamic>>)) {
        upcomingItems.add({...j, 'clientName': client, 'lpmNumber': lpm});
      }
    }

    final todayTotal = todayItems.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());
    final overdueTotal = overdueItems.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());
    final upcomingTotal = upcomingItems.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (todayItems.isNotEmpty)
          _SectionGroup(label: 'Today', total: todayTotal, items: todayItems, expanded: _todayExpanded, onToggle: () => setState(() => _todayExpanded = !_todayExpanded), isToday: true),
        if (overdueItems.isNotEmpty)
          _SectionGroup(label: 'Overdue', total: overdueTotal, items: overdueItems, expanded: _overdueExpanded, onToggle: () => setState(() => _overdueExpanded = !_overdueExpanded)),
        if (upcomingItems.isNotEmpty)
          _SectionGroup(label: 'Upcoming', total: upcomingTotal, items: upcomingItems, expanded: _upcomingExpanded, onToggle: () => setState(() => _upcomingExpanded = !_upcomingExpanded)),
      ],
    );
  }
}

class _SectionGroup extends StatelessWidget {
  final String label;
  final double total;
  final List<Map<String, dynamic>> items;
  final bool expanded;
  final VoidCallback onToggle;
  final bool isToday;

  const _SectionGroup({required this.label, required this.total, required this.items, required this.expanded, required this.onToggle, this.isToday = false});

  List<Widget> _buildClientCards(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> byClient = {};
    for (final item in items) {
      final client = item['clientName'] as String? ?? (item['data'] as Map<String, dynamic>)['client'] ?? '';
      byClient.putIfAbsent(client, () => []).add(item);
    }
    final fmt = NumberFormat('#,##,##0', 'en_IN');

    return byClient.entries.map((entry) {
      final client = entry.key;
      final clientItems = entry.value;
      final totalAmount = clientItems.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());
      final date = clientItems.map((i) => i['date'] as DateTime).reduce((a, b) => a.isBefore(b) ? a : b);
      final lpm = (clientItems.first['lpmNumber'] ?? '').toString();

      return GestureDetector(
        onTap: () => context.push('/client-detail', extra: {'client': client}),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(color: Colors.yellow.shade200, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('IMP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${clientItems.length} pending job(s)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    if (lpm.isNotEmpty)
                      Text('LPM: $lpm', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Today', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                    )
                  else
                    Text(DateFormat('dd/MM/yyyy').format(date), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(height: 6),
                  Text('₹${fmt.format(totalAmount.toInt())}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,##0', 'en_IN');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text('₹${fmt.format(total.toInt())}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(width: 4),
                    Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (expanded) ..._buildClientCards(context),
        const Divider(height: 1),
      ],
    );
  }
}

class _OverdueTabView extends StatelessWidget {
  final List<Map<String, dynamic>> displayList;
  const _OverdueTabView({required this.displayList});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,##0', 'en_IN');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final c = displayList[index];
        final client = c['client'] as String;
        final overdueJobs = c['overdueJobs'] as List<Map<String, dynamic>>;
        final overdueTotal = c['overdueTotal'] as double;
        final lpm = (c['lpmNumber'] ?? '').toString();

        return GestureDetector(
          onTap: () => context.push('/client-detail', extra: {'client': client}),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(color: Colors.yellow.shade200, borderRadius: BorderRadius.circular(8)),
                  child: const Center(child: Text('IMP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('${overdueJobs.length} overdue job(s)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (lpm.isNotEmpty)
                        Text('LPM: $lpm', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${fmt.format(overdueTotal.toInt())}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Text('Overdue', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}