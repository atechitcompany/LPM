import 'package:flutter/material.dart';
import '../models/payment_material_model.dart';

class PaymentBillTable extends StatefulWidget {
  final List<PaymentMaterialModel> materials;

  const PaymentBillTable({super.key, required this.materials});

  @override
  State<PaymentBillTable> createState() => _PaymentBillTableState();
}

class _PaymentBillTableState extends State<PaymentBillTable> {
  late List<Map<String, TextEditingController>> _controllers;
  late List<double> _quantities;

  // Define which materials use dimensions instead of single qty
  static const Map<String, List<String>> _dimensionFields = {
    'tile': ['Length', 'Breadth'],
    'flooring': ['Length', 'Breadth'],
    'carpet': ['Length', 'Breadth'],
    'glass': ['Length', 'Breadth'],
    'wallpaper': ['Length', 'Breadth'],
    'paint': ['Length', 'Breadth'],
    'pipe': ['Length'],
    'rod': ['Length'],
    'beam': ['Length'],
    'plank': ['Length', 'Breadth'],
    'sheet': ['Length', 'Breadth'],
    'slab': ['Length', 'Breadth'],
    'brick': ['Length', 'Breadth', 'Height'],
    'block': ['Length', 'Breadth', 'Height'],
    'concrete': ['Length', 'Breadth', 'Height'],
    'soil': ['Length', 'Breadth', 'Height'],
    'sand': ['Length', 'Breadth', 'Height'],
    'gravel': ['Length', 'Breadth', 'Height'],
  };

  List<String> _getFieldsForMaterial(String material) {
    final lower = material.toLowerCase();
    for (final entry in _dimensionFields.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return ['Quantity'];
  }

  @override
  void initState() {
    super.initState();
    _quantities = List.filled(widget.materials.length, 1.0);
    _controllers = widget.materials.map((item) {
      final fields = _getFieldsForMaterial(item.material);
      return {for (final f in fields) f: TextEditingController()};
    }).toList();
  }

  @override
  void dispose() {
    for (final map in _controllers) {
      for (final c in map.values) c.dispose();
    }
    super.dispose();
  }

  void _updateQuantity(int index) {

    final map = _controllers[index];

    double product = 1.0;

    bool anyFilled = false;

    for (final c in map.values) {

      final v =
          double.tryParse(c.text) ?? 1.0;

      if (c.text.trim().isNotEmpty) {
        anyFilled = true;
      }

      product *= v;
    }

    setState(() {

      /// DEFAULT = 1
      _quantities[index] =
      anyFilled ? product : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.materials.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text("No bill materials found"),
      );
    }

    double totalAmount = 0;
    for (int i = 0; i < widget.materials.length; i++) {
      totalAmount += widget.materials[i].rate * _quantities[i];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text("Sr. No.", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Material", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Material Name", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Rate", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Qty / Size", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(widget.materials.length, (i) {
                final item = widget.materials[i];
                final fields = _getFieldsForMaterial(item.material);
                final amount = item.rate * _quantities[i];

                return DataRow(cells: [
                  DataCell(Text(item.srNo.toString())),
                  DataCell(Text(item.material)),
                  DataCell(SizedBox(width: 220, child: Text(item.materialName))),
                  DataCell(Text("₹ ${item.rate.toStringAsFixed(2)}")),
                  DataCell(
                    SizedBox(
                      width: fields.length * 90.0,
                      child: Row(
                        children: fields.map((field) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: SizedBox(
                              width: 80,
                              child: TextField(
                                controller: _controllers[i][field],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: field,
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                onChanged: (_) => _updateQuantity(i),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  DataCell(Text("₹ ${amount.toStringAsFixed(2)}")),
                ]);
              }),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Grand Total : ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "₹ ${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}