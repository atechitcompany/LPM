// ══════════════════════════════════════════════════════════════════════════════
// FILE 2: customer_quotation_detail_screen.dart  (replace existing)
// ══════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerQuotationDetailScreen extends StatefulWidget {
  final String docId;
  const CustomerQuotationDetailScreen({super.key, required this.docId});

  @override
  State<CustomerQuotationDetailScreen> createState() =>
      _CustomerQuotationDetailScreenState();
}

class _CustomerQuotationDetailScreenState
    extends State<CustomerQuotationDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('quotation_pending')
          .doc(widget.docId)
          .get();

      if (!doc.exists) {
        doc = await FirebaseFirestore.instance
            .collection('demo_customer_form')
            .doc(widget.docId)
            .get();
      }

      if (mounted) setState(() { _data = doc.data(); _loading = false; });
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value.isEmpty ? '—' : value,
          style: TextStyle(
              fontSize: 14,
              color: value.isEmpty ? Colors.grey : Colors.black87),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quotation Detail'),
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      // ── Edit FAB ──────────────────────────────────────────────────────────
      floatingActionButton: _data == null
          ? null
          : FloatingActionButton(
        onPressed: () async {
          // Navigate to edit form, then refresh on return
          await context.push(
            '/customer-quotation-edit/${widget.docId}',
          );
          _fetch(); // refresh after editing
        },
        backgroundColor: const Color(0xFFF8D94B),
        foregroundColor: Colors.black,
        child: const Icon(Icons.edit),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
          ? const Center(child: Text('Not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field('Party Name', _data!['PartyName'] ?? _data!['partyName'] ?? ''),
            _field('Delivery At', _data!['DeliveryAt'] ?? _data!['deliveryAt'] ?? ''),
            _field('Job Name', _data!['ParticularJobName'] ?? _data!['jobName'] ?? ''),
            _field('Machine Name', _data!['MachineName'] ?? _data!['machineName'] ?? ''),
            _field('Ply Wood Size & Griper', _data!['PlywoodSizeGriper'] ?? _data!['plywoodSizeGriper'] ?? ''),
            _field('Rubber Or Without Rubber', _data!['RubberOrWithout'] ?? _data!['rubberOrWithout'] ?? ''),
            _field('Cutting Rule', _data!['CuttingRule'] ?? _data!['cuttingRule'] ?? ''),
            _field('Creasing Rule', _data!['CreasingRule'] ?? _data!['creasingRule'] ?? ''),
            _field('Material To Punch', _data!['MaterialToPunch'] ?? _data!['materialToPunch'] ?? ''),
            _field('Flute', _data!['Flute'] ?? _data!['flute'] ?? ''),
            _field('Board Compressed Thickness', _data!['BoardCompressedThickness'] ?? _data!['boardCompressedThickness'] ?? ''),
            _field('Center Notch', _data!['CenterNotch'] ?? _data!['centerNotch'] ?? ''),
            _field('Ply Wood Thickness', _data!['PlywoodThickness'] ?? _data!['plywoodThickness'] ?? ''),
            _field('Perforation', _data!['Perforation'] ?? _data!['perforation'] ?? ''),
            _field('Partinex', _data!['Partinex'] ?? _data!['partinex'] ?? ''),
            _field('Nicking', _data!['Nicking'] ?? _data!['nicking'] ?? ''),
            _field('Broaching', _data!['Broaching'] ?? _data!['broaching'] ?? ''),
            _field('Blade Welding', _data!['BladeWelding'] ?? _data!['bladeWelding'] ?? ''),
            _field('Stripping Male & Female', _data!['StrippingMaleFemale'] ?? _data!['strippingMaleFemale'] ?? ''),
            _field('Sanwitch Die', _data!['SanwitchDie'] ?? _data!['sanwitchDie'] ?? ''),
          ],
        ),
      ),
    );
  }
}