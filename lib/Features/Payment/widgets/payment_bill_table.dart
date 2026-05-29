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
  String _selectedGST = "No GST";
  double _numberOfPayments = 1;

  late List<TextEditingController> _amountControllers;
  late List<DateTime?> _paymentDates;
  late List<String> _paymentStatuses;

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
    _initInstallments(1);
  }

  void _initInstallments(int count) {
    _amountControllers = List.generate(count, (_) => TextEditingController());
    _paymentDates = List<DateTime?>.filled(count, null, growable: true);
    _paymentStatuses = List<String>.filled(count, "No", growable: true);
    _redistributeAmounts();
  }

  void _redistributeAmounts() {
    final count = _numberOfPayments.toInt();
    if (count == 0) return;
    final each = (_finalAmount / count).toStringAsFixed(2);
    for (final c in _amountControllers) {
      c.text = each;
    }
  }

  /// Called when Payment 1 (index 0) amount is manually edited.
  void _onPayment1Changed(String value) {
    final count = _numberOfPayments.toInt();
    if (count <= 1) return;
    final entered = double.tryParse(value) ?? 0.0;
    final remaining = _finalAmount - entered;
    final each = (remaining / (count - 1)).toStringAsFixed(2);
    for (int i = 1; i < count; i++) {
      _amountControllers[i].text = each;
    }
  }

  @override
  void dispose() {
    for (final map in _controllers) {
      for (final c in map.values) c.dispose();
    }
    for (final c in _amountControllers) c.dispose();
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
    setState(() {
      _quantities[index] = anyFilled ? product : 1.0;
      _redistributeAmounts();
    });
  }

  double get _totalAmount {
    double total = 0;
    for (int i = 0; i < widget.materials.length; i++) {
      total += widget.materials[i].rate * _quantities[i];
    }
    return total;
  }

  double get _gstAmount => _selectedGST == "No GST" ? 0.0 : _totalAmount * 0.18;
  double get _cgstAmount => _gstAmount / 2;
  double get _sgstAmount => _gstAmount / 2;
  double get _finalAmount => _totalAmount + _gstAmount;

  void _onDateSelected(int index, DateTime picked) {
    setState(() {
      _paymentDates[index] = picked;
      for (int j = index + 1; j < _numberOfPayments.toInt(); j++) {
        _paymentDates[j] = DateTime(
          picked.year,
          picked.month + (j - index),
          picked.day,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.materials.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: Text("No bill materials found"),
      ));
    }

    final count = _numberOfPayments.toInt();

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
                    DropdownMenuItem(value: "No GST", child: Text("No GST")),
                    DropdownMenuItem(value: "GST", child: Text("GST")),
                    DropdownMenuItem(value: "IGST", child: Text("IGST")),
                  ],
                  onChanged: (v) => setState(() {
                    _selectedGST = v!;
                    _redistributeAmounts();
                  }),
                ),
                const SizedBox(height: 20),
                Text(
                  "Payments : $count",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _numberOfPayments,
                  min: 1, max: 10, divisions: 9,
                  label: count.toString(),
                  onChanged: (v) {
                    final newCount = v.toInt();
                    final oldCount = _numberOfPayments.toInt();
                    setState(() {
                      _numberOfPayments = v;
                      if (newCount > oldCount) {
                        for (int i = oldCount; i < newCount; i++) {
                          _amountControllers.add(TextEditingController());
                          _paymentDates.add(null);
                          _paymentStatuses.add("No");
                        }
                      } else {
                        for (int i = oldCount - 1; i >= newCount; i--) {
                          _amountControllers[i].dispose();
                          _amountControllers.removeAt(i);
                          _paymentDates.removeAt(i);
                          _paymentStatuses.removeAt(i);
                        }
                      }
                      _redistributeAmounts();
                    });
                  },
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

          // GST Bifurcation Section
          if (_selectedGST != "No GST")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sub Total", style: TextStyle(fontSize: 14)),
                        Text("₹ ${_totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const Divider(),
                    if (_selectedGST == "GST") ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("CGST (9%)", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                          Text("₹ ${_cgstAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("SGST (9%)", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                          Text("₹ ${_sgstAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                        ],
                      ),
                    ] else if (_selectedGST == "IGST")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("IGST (18%)", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                          Text("₹ ${_gstAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                        ],
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Payment Installments",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...List.generate(count, (i) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Payment ${i + 1}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountControllers[i],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Amount",
                          prefixText: "₹ ",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: i == 0 ? _onPayment1Changed : null,
                        readOnly: i != 0 && count > 1,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _paymentDates[i] ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) _onDateSelected(i, picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range),
                              const SizedBox(width: 12),
                              Text(_paymentDates[i] == null
                                  ? "Select Date"
                                  : "${_paymentDates[i]!.day}/${_paymentDates[i]!.month}/${_paymentDates[i]!.year}"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _paymentStatuses[i],
                        decoration: InputDecoration(
                          labelText: "Payment Status",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(value: "No", child: Text("No")),
                          DropdownMenuItem(value: "Yes", child: Text("Yes")),
                          DropdownMenuItem(value: "Partial", child: Text("Partial")),
                        ],
                        onChanged: (v) => setState(() => _paymentStatuses[i] = v!),
                      ),
                    ],
                  ),
                )),
              ],
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