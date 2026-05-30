import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/payment_material_model.dart';

class PaymentBillTable extends StatefulWidget {
  final List<PaymentMaterialModel> materials;
  final String selectedClient;
  final String selectedJob;
  final String lpmNumber;

  const PaymentBillTable({
    super.key,
    required this.materials,
    required this.selectedClient,
    required this.selectedJob,
    required this.lpmNumber,
  });

  @override
  State<PaymentBillTable> createState() => PaymentBillTableState();
}

class PaymentBillTableState extends State<PaymentBillTable> {
  late List<Map<String, TextEditingController>> _controllers;
  late List<double> _quantities;
  String _selectedGST = "No GST";
  double _numberOfPayments = 1;

  late List<TextEditingController> _amountControllers;
  late List<DateTime?> _paymentDates;
  late List<String> _paymentStatuses;

  bool _isSubmitting = false;

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
    for (final c in _amountControllers) c.text = each;
  }

  void _onAmountChanged(int index, String value) {
    final count = _numberOfPayments.toInt();
    if (count <= 1) return;
    double enteredSum = 0;
    for (int i = 0; i <= index; i++) {
      enteredSum += (i == index)
          ? (double.tryParse(value) ?? 0.0)
          : (double.tryParse(_amountControllers[i].text) ?? 0.0);
    }
    final remaining = _finalAmount - enteredSum;
    final futureCount = count - index - 1;
    if (futureCount > 0) {
      final each = (remaining / futureCount).toStringAsFixed(2);
      setState(() {
        for (int i = index + 1; i < count; i++) _amountControllers[i].text = each;
      });
    }
  }

  bool get _amountValid {
    final sum = _amountControllers.fold(0.0, (a, c) => a + (double.tryParse(c.text) ?? 0.0));
    return (sum - _finalAmount).abs() < 0.01;
  }

  @override
  void dispose() {
    for (final map in _controllers) for (final c in map.values) c.dispose();
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
        _paymentDates[j] = DateTime(picked.year, picked.month + (j - index), picked.day);
      }
    });
  }

  Future<void> _submitPayment() async {
    if (widget.lpmNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("LPM number not found.")));
      return;
    }
    setState(() { _isSubmitting = true; });
    try {
      final count = _numberOfPayments.toInt();
      final installments = List.generate(count, (i) => {
        "installmentNumber": i + 1,
        "amount": double.tryParse(_amountControllers[i].text) ?? 0.0,
        "date": _paymentDates[i] != null ? Timestamp.fromDate(_paymentDates[i]!) : null,
        "status": _paymentStatuses[i],
      });

      final materialsData = List.generate(widget.materials.length, (i) {
        final item = widget.materials[i];
        final dims = <String, double>{};
        _controllers[i].forEach((field, ctrl) { dims[field] = double.tryParse(ctrl.text) ?? 0.0; });
        return {
          "srNo": item.srNo, "material": item.material,
          "materialName": item.materialName, "rate": item.rate,
          "quantity": _quantities[i], "amount": item.rate * _quantities[i],
          "dimensions": dims,
        };
      });

      await FirebaseFirestore.instance.collection("payments").doc(widget.lpmNumber).set({
        "client": widget.selectedClient, "job": widget.selectedJob,
        "lpmNumber": widget.lpmNumber, "gstType": _selectedGST,
        "subTotal": _totalAmount, "gstAmount": _gstAmount,
        "cgstAmount": _cgstAmount, "sgstAmount": _sgstAmount,
        "grandTotal": _finalAmount, "materials": materialsData,
        "installments": installments, "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Payment recorded!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.materials.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No bill materials found")));
    }
    final count = _numberOfPayments.toInt();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
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
                    labelText: "GST Type", filled: true, fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: "No GST", child: Text("No GST")),
                    DropdownMenuItem(value: "GST", child: Text("GST")),
                    DropdownMenuItem(value: "IGST", child: Text("IGST")),
                  ],
                  onChanged: (v) => setState(() { _selectedGST = v!; _redistributeAmounts(); }),
                ),
                const SizedBox(height: 20),
                Text("Payments : $count", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Slider(
                  value: _numberOfPayments, min: 1, max: 10, divisions: 9,
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
                              labelText: field, isDense: true,
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

          if (_selectedGST != "No GST")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Sub Total", style: TextStyle(fontSize: 14)),
                      Text("₹ ${_totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14)),
                    ]),
                    const Divider(),
                    if (_selectedGST == "GST") ...[
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("CGST (9%)", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                        Text("₹ ${_cgstAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                      ]),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("SGST (9%)", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                        Text("₹ ${_sgstAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                      ]),
                    ] else if (_selectedGST == "IGST")
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("IGST (18%)", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                        Text("₹ ${_gstAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                      ]),
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
                const Text("Payment Installments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...List.generate(count, (i) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Payment ${i + 1}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountControllers[i],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Amount", prefixText: "₹ ", filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (v) { _onAmountChanged(i, v); setState(() {}); },
                        readOnly: i != 0 && count > 1 && i == count - 1,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _paymentDates[i] ?? DateTime.now(),
                            firstDate: DateTime(2000), lastDate: DateTime(2100),
                          );
                          if (picked != null) _onDateSelected(i, picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(children: [
                            const Icon(Icons.date_range), const SizedBox(width: 12),
                            Text(_paymentDates[i] == null
                                ? "Select Date"
                                : "${_paymentDates[i]!.day}/${_paymentDates[i]!.month}/${_paymentDates[i]!.year}"),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _paymentStatuses[i],
                        decoration: InputDecoration(
                          labelText: "Payment Status", filled: true, fillColor: Colors.white,
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
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  const Text("Grand Total : ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("₹ ${_finalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                ]),
                const SizedBox(height: 4),
                if (!_amountValid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Sum of installments must equal Grand Total (₹ ${_finalAmount.toStringAsFixed(2)})",
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: (_isSubmitting || !_amountValid) ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}