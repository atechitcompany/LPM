import 'package:flutter/material.dart';
import '../models/payment_material_model.dart';
import '../models/installment_payment_model.dart';

class PaymentBillTable extends StatefulWidget {
  final List<PaymentMaterialModel> materials;
  const PaymentBillTable({super.key, required this.materials});

  @override
  State<PaymentBillTable> createState() => _PaymentBillTableState();
}

class _PaymentBillTableState extends State<PaymentBillTable> {
  late List<Map<String, TextEditingController>> _controllers;
  late List<double> _quantities;
  String _selectedGST = "GST";
  double _numberOfPayments = 1;
  DateTime? _firstPaymentDate;

  static const Map<String, List<String>> _dimensionFields = {
    'tile': ['Length', 'Breadth'], 'flooring': ['Length', 'Breadth'],
    'carpet': ['Length', 'Breadth'], 'glass': ['Length', 'Breadth'],
    'wallpaper': ['Length', 'Breadth'], 'paint': ['Length', 'Breadth'],
    'pipe': ['Length'], 'rod': ['Length'], 'beam': ['Length'],
    'plank': ['Length', 'Breadth'], 'sheet': ['Length', 'Breadth'],
    'slab': ['Length', 'Breadth'],
    'brick': ['Length', 'Breadth', 'Height'], 'block': ['Length', 'Breadth', 'Height'],
    'concrete': ['Length', 'Breadth', 'Height'], 'soil': ['Length', 'Breadth', 'Height'],
    'sand': ['Length', 'Breadth', 'Height'], 'gravel': ['Length', 'Breadth', 'Height'],
  };

  List<String> _fieldsFor(String material) {
    final lower = material.toLowerCase();
    for (final e in _dimensionFields.entries) {
      if (lower.contains(e.key)) return e.value;
    }
    return ['Quantity'];
  }

  @override
  void initState() {
    super.initState();
    _quantities = List.filled(widget.materials.length, 1.0);
    _controllers = widget.materials.map((item) {
      final fields = _fieldsFor(item.material);
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
      if (c.text.trim().isNotEmpty) anyFilled = true;
      product *= double.tryParse(c.text) ?? 1.0;
    }
    setState(() => _quantities[index] = anyFilled ? product : 1.0);
  }

  double get _totalAmount {
    double total = 0;
    for (int i = 0; i < widget.materials.length; i++) {
      total += widget.materials[i].rate * _quantities[i];
    }
    return total;
  }

  double get _finalAmount {
    final total = _totalAmount;
    if (_selectedGST == "No GST") return total;
    return total * 1.18; // GST and IGST both 18%
  }

  List<InstallmentPaymentModel> get _installments {
    if (_firstPaymentDate == null) return [];
    final count = _numberOfPayments.toInt();
    final each = _finalAmount / count;
    return List.generate(count, (i) => InstallmentPaymentModel(
      amount: each,
      paymentDate: DateTime(
        _firstPaymentDate!.year,
        _firstPaymentDate!.month + i,
        _firstPaymentDate!.day,
      ),
      paymentStatus: "No",
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.materials.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("No bill materials found"),
      ));
    }

    final installments = _installments;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedGST,
                  decoration: InputDecoration(
                    labelText: "GST Type",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: "GST", child: Text("GST")),
                    DropdownMenuItem(value: "IGST", child: Text("IGST")),
                    DropdownMenuItem(value: "No GST", child: Text("No GST")),
                  ],
                  onChanged: (v) => setState(() => _selectedGST = v!),
                ),
                const SizedBox(height: 20),
                Text(
                  "Payments : ${_numberOfPayments.toInt()}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _numberOfPayments,
                  min: 1, max: 10, divisions: 9,
                  label: _numberOfPayments.toInt().toString(),
                  onChanged: (v) => setState(() => _numberOfPayments = v),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _firstPaymentDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 12),
                        Text(_firstPaymentDate == null
                            ? "Select First Payment Date"
                            : "${_firstPaymentDate!.day}/${_firstPaymentDate!.month}/${_firstPaymentDate!.year}"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
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
                final fields = _fieldsFor(item.material);
                return DataRow(cells: [
                  DataCell(Text(item.srNo.toString())),
                  DataCell(Text(item.material)),
                  DataCell(SizedBox(width: 220, child: Text(item.materialName))),
                  DataCell(Text("₹ ${item.rate.toStringAsFixed(2)}")),
                  DataCell(SizedBox(
                    width: fields.length * 90.0,
                    child: Row(
                      children: fields.map((field) => Padding(
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
                      )).toList(),
                    ),
                  )),
                  DataCell(Text("₹ ${(item.rate * _quantities[i]).toStringAsFixed(2)}")),
                ]);
              }),
            ),
          ),

          if (installments.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Payment Installments",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: installments.asMap().entries.map((e) => ListTile(
                        leading: CircleAvatar(child: Text("${e.key + 1}")),
                        title: Text("₹ ${e.value.amount.toStringAsFixed(2)}"),
                        subtitle: Text(
                            "${e.value.paymentDate.day}/${e.value.paymentDate.month}/${e.value.paymentDate.year}"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(e.value.paymentStatus),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],

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
                const Text("Grand Total : ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "₹ ${_finalAmount.toStringAsFixed(2)}",
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