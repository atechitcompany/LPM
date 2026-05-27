import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerQuotationDetailScreen extends StatefulWidget {
  final String docId;
  const CustomerQuotationDetailScreen({super.key, required this.docId});

  @override
  State<CustomerQuotationDetailScreen> createState() => _CustomerQuotationDetailScreenState();
}

class _CustomerQuotationDetailScreenState extends State<CustomerQuotationDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("demo_customer_form")
          .doc(widget.docId)
          .get();
      if (mounted) {
        setState(() {
          _data = doc.data();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching quotation: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
            value.isEmpty ? "—" : value,
            style: TextStyle(
              fontSize: 14,
              color: value.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Quotation Detail"),
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
          ? const Center(child: Text("Not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field("Party Name", _data!["partyName"]?.toString() ?? ""),
            _field("Delivery At", _data!["deliveryAt"]?.toString() ?? ""),
            _field("Job Name", _data!["jobName"]?.toString() ?? ""),
            _field("Machine Name", _data!["machineName"]?.toString() ?? ""),
            _field("Ply Wood Size & Griper", _data!["plywoodSizeGriper"]?.toString() ?? ""),
            _field("Rubber Or Without Rubber", _data!["rubberOrWithout"]?.toString() ?? ""),
            _field("Cutting Rule", _data!["cuttingRule"]?.toString() ?? ""),
            _field("Creasing Rule", _data!["creasingRule"]?.toString() ?? ""),
            _field("Material To Punch", _data!["materialToPunch"]?.toString() ?? ""),
            _field("Flute", _data!["flute"]?.toString() ?? ""),
            _field("Board Compressed Thickness", _data!["boardCompressedThickness"]?.toString() ?? ""),
            _field("Center Notch", _data!["centerNotch"]?.toString() ?? ""),
            _field("Ply Wood Thickness", _data!["plywoodThickness"]?.toString() ?? ""),
            _field("Perforation", _data!["perforation"]?.toString() ?? ""),
            _field("Partinex", _data!["partinex"]?.toString() ?? ""),
            _field("Nicking", _data!["nicking"]?.toString() ?? ""),
            _field("Broaching", _data!["broaching"]?.toString() ?? ""),
            _field("Blade Welding", _data!["bladeWelding"]?.toString() ?? ""),
            _field("Stripping Male & Female", _data!["strippingMaleFemale"]?.toString() ?? ""),
            _field("Sanwitch Die", _data!["sanwitchDie"]?.toString() ?? ""),
          ],
        ),
      ),
    );
  }
}