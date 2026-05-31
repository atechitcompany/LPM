import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ClientDetailPage extends StatelessWidget {
  final String client;

  const ClientDetailPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(client, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payments")
            .where("client", isEqualTo: client)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No payments found."));
          }

          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          final fmt = NumberFormat('#,##,##0', 'en_IN');

          final List<Map<String, dynamic>> todayItems = [];
          final List<Map<String, dynamic>> overdueItems = [];
          final List<Map<String, dynamic>> upcomingItems = [];

          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            final installments = (data["installments"] as List<dynamic>?) ?? [];

            for (final inst in installments) {
              if (inst["status"] == "Yes") continue;
              final ts = inst["date"] as Timestamp?;
              if (ts == null) continue;
              final instDate = DateTime(ts.toDate().year, ts.toDate().month, ts.toDate().day);
              final amount = (inst["amount"] ?? 0.0) as num;
              final item = {
                'docId': docId,
                'data': data,
                'installment': inst,
                'date': instDate,
                'amount': amount,
              };
              if (instDate == todayDate) {
                todayItems.add(item);
              } else if (instDate.isBefore(todayDate)) {
                overdueItems.add(item);
              } else {
                upcomingItems.add(item);
              }
            }
          }

          final totalPending = [...todayItems, ...overdueItems, ...upcomingItems]
              .fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());
          final overdueTotal = overdueItems.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());

          return _ClientDetailBody(
            client: client,
            todayItems: todayItems,
            overdueItems: overdueItems,
            upcomingItems: upcomingItems,
            totalPending: totalPending,
            overdueTotal: overdueTotal,
            fmt: fmt,
            todayDate: todayDate,
          );
        },
      ),
    );
  }
}

class _ClientDetailBody extends StatefulWidget {
  final String client;
  final List<Map<String, dynamic>> todayItems;
  final List<Map<String, dynamic>> overdueItems;
  final List<Map<String, dynamic>> upcomingItems;
  final double totalPending;
  final double overdueTotal;
  final NumberFormat fmt;
  final DateTime todayDate;

  const _ClientDetailBody({
    required this.client,
    required this.todayItems,
    required this.overdueItems,
    required this.upcomingItems,
    required this.totalPending,
    required this.overdueTotal,
    required this.fmt,
    required this.todayDate,
  });

  @override
  State<_ClientDetailBody> createState() => _ClientDetailBodyState();
}

class _ClientDetailBodyState extends State<_ClientDetailBody> {
  bool _clientExpanded = true;
  bool _totalExpanded = true;
  bool _todayExpanded = true;
  bool _overdueExpanded = true;
  bool _upcomingExpanded = true;
  bool _followUpExpanded = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailSection(
          title: 'Client Name',
          expanded: _clientExpanded,
          onTap: () => setState(() => _clientExpanded = !_clientExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(widget.client, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 10),

        _DetailSection(
          title: 'Total Pending Amount',
          expanded: _totalExpanded,
          onTap: () => setState(() => _totalExpanded = !_totalExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pending', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('₹${widget.fmt.format(widget.totalPending.toInt())}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                if (widget.overdueTotal > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Overdue', style: TextStyle(fontSize: 13, color: Colors.red)),
                      Text('₹${widget.fmt.format(widget.overdueTotal.toInt())}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        if (widget.todayItems.isNotEmpty) ...[
          _DetailSection(
            title: 'Today',
            expanded: _todayExpanded,
            onTap: () => setState(() => _todayExpanded = !_todayExpanded),
            child: _JobList(items: widget.todayItems, todayDate: widget.todayDate, fmt: widget.fmt),
          ),
          const SizedBox(height: 10),
        ],

        if (widget.overdueItems.isNotEmpty) ...[
          _DetailSection(
            title: 'Overdue',
            expanded: _overdueExpanded,
            onTap: () => setState(() => _overdueExpanded = !_overdueExpanded),
            child: _JobList(items: widget.overdueItems, todayDate: widget.todayDate, fmt: widget.fmt),
          ),
          const SizedBox(height: 10),
        ],

        if (widget.upcomingItems.isNotEmpty) ...[
          _DetailSection(
            title: 'Upcoming',
            expanded: _upcomingExpanded,
            onTap: () => setState(() => _upcomingExpanded = !_upcomingExpanded),
            child: _JobList(items: widget.upcomingItems, todayDate: widget.todayDate, fmt: widget.fmt),
          ),
          const SizedBox(height: 10),
        ],

        _DetailSection(
          title: 'Follow Up Details',
          expanded: _followUpExpanded,
          onTap: () => setState(() => _followUpExpanded = !_followUpExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _ActionBtn(icon: Icons.phone, color: Colors.blue, label: 'Call', onTap: () {}),
                const SizedBox(width: 12),
                _ActionBtn(icon: Icons.chat, color: Colors.green, label: 'WhatsApp', onTap: () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JobList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final DateTime todayDate;
  final NumberFormat fmt;

  const _JobList({required this.items, required this.todayDate, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final data = item['data'] as Map<String, dynamic>;
        final date = item['date'] as DateTime;
        final amount = item['amount'] as num;
        final job = data['job'] ?? '';
        final isOverdue = date.isBefore(todayDate);
        final isToday = date == todayDate;

        return GestureDetector(
          onTap: () => context.push('/edit-payment', extra: {
            'docId': item['docId'],
            'data': data,
          }),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isOverdue ? Colors.red.shade100 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('LPM: ${item['docId']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${fmt.format(amount.toInt())}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(10)),
                        child: const Text('Today', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                      )
                    else
                      Text(
                        DateFormat('dd/MM/yyyy').format(date),
                        style: TextStyle(fontSize: 10, color: isOverdue ? Colors.red.shade400 : Colors.grey.shade500),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _DetailSection({required this.title, required this.expanded, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.yellow.shade200, borderRadius: BorderRadius.circular(8)),
                    child: const Center(child: Text('IMP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          if (expanded) child,
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}