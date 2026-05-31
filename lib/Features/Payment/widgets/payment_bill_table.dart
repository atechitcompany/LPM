import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/payment_material_model.dart';

class PaymentBillTable extends StatefulWidget {
  final List<PaymentMaterialModel> materials;
  final String selectedClient;
  final String selectedJob;
  final String lpmNumber;
  final double clientDiscount;
  final VoidCallback? onPaymentRecorded;

  const PaymentBillTable({
    super.key,
    required this.materials,
    required this.selectedClient,
    required this.selectedJob,
    required this.lpmNumber,
    this.clientDiscount = 0.0,
    this.onPaymentRecorded,
  });

  @override
  State<PaymentBillTable> createState() => PaymentBillTableState();
}

class PaymentBillTableState extends State<PaymentBillTable> {
  late List<PaymentMaterialModel> _materials;
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
    _materials = List<PaymentMaterialModel>.of(widget.materials, growable: true);
    _quantities = List<double>.generate(_materials.length, (_) => 1.0, growable: true);
    _controllers = _materials.map((item) {
      final fields = _fieldsFor(item.material);
      return {for (final f in fields) f: TextEditingController()};
    }).toList(growable: true);
    _initInstallments(1);
  }

  void _initInstallments(int count) {
    _amountControllers = List<TextEditingController>.generate(count, (_) => TextEditingController(), growable: true);
    _paymentDates = List<DateTime?>.generate(count, (_) => null, growable: true);
    _paymentStatuses = List<String>.generate(count, (_) => "No", growable: true);
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

  bool get _allDatesSelected => _paymentDates.every((d) => d != null);

  @override
  void dispose() {
    for (final map in _controllers) for (final c in map.values) c.dispose();
    for (final c in _amountControllers) c.dispose();
    super.dispose();
  }

  void _updateQuantity(int index) {
    if (index >= _controllers.length) return;
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
    final length = _materials.length < _quantities.length ? _materials.length : _quantities.length;
    for (int i = 0; i < length; i++) {
      total += _materials[i].rate * _quantities[i];
    }
    return total;
  }

  double get _gstAmount => _selectedGST == "No GST" ? 0.0 : _totalAmount * 0.18;
  double get _cgstAmount => _gstAmount / 2;
  double get _sgstAmount => _gstAmount / 2;
  double get _discountAmount => widget.clientDiscount > 0 ? (_totalAmount + _gstAmount) * (widget.clientDiscount / 100) : 0.0;
  double get _finalAmount => _totalAmount + _gstAmount - _discountAmount;

  void _onDateSelected(int index, DateTime picked) {
    setState(() {
      _paymentDates[index] = picked;
      for (int j = index + 1; j < _numberOfPayments.toInt(); j++) {
        _paymentDates[j] = DateTime(picked.year, picked.month + (j - index), picked.day);
      }
    });
  }

  void _showAddItemDialog() {
    final materialCtrl = TextEditingController();
    final materialNameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final srNo = _materials.isEmpty ? 1 : (_materials.last.srNo + 1);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.add_shopping_cart, color: Colors.indigo.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            const Text("Add Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(materialCtrl, "Material Type", Icons.category_outlined),
              const SizedBox(height: 12),
              _dialogField(materialNameCtrl, "Material Name", Icons.label_outline),
              const SizedBox(height: 12),
              _dialogField(rateCtrl, "Rate (₹)", Icons.currency_rupee, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              final mat = materialCtrl.text.trim();
              final name = materialNameCtrl.text.trim();
              final rate = double.tryParse(rateCtrl.text.trim()) ?? 0.0;
              if (mat.isEmpty || name.isEmpty || rate <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields correctly")),
                );
                return;
              }
              final newItem = PaymentMaterialModel(
                srNo: srNo,
                material: mat,
                materialName: name,
                rate: rate,
                quantityOrSize: "",
                amount: 0,
              );
              setState(() {
                _materials.add(newItem);
                _quantities.add(1.0);
                final fields = _fieldsFor(mat);
                _controllers.add({for (final f in fields) f: TextEditingController()});
                _redistributeAmounts();
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.indigo.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _controllers[index].values.forEach((c) => c.dispose());
      _materials.removeAt(index);
      _quantities.removeAt(index);
      _controllers.removeAt(index);
      _redistributeAmounts();
    });
  }

  Future<void> _submitPayment() async {
    if (!_allDatesSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select dates for all payment installments.")),
      );
      return;
    }
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
        "date": Timestamp.fromDate(_paymentDates[i]!),
        "status": _paymentStatuses[i],
      });

      final materialsData = List.generate(_materials.length, (i) {
        final item = _materials[i];
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
        "discountPercent": widget.clientDiscount,
        "discountAmount": _discountAmount,
        "grandTotal": _finalAmount, "materials": materialsData,
        "installments": installments, "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        widget.onPaymentRecorded?.call();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _numberOfPayments.toInt();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo.shade600, Colors.indigo.shade400]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                const Expanded(child: Text("Payment Bill", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                GestureDetector(
                  onTap: _showAddItemDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text("Add Item", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_materials.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text("No materials added", style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddItemDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add First Item"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: DropdownButtonFormField<String>(
                value: _selectedGST,
                decoration: InputDecoration(
                  labelText: "GST Type",
                  prefixIcon: Icon(Icons.percent, size: 18, color: Colors.indigo.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: "No GST", child: Text("No GST")),
                  DropdownMenuItem(value: "GST", child: Text("GST (CGST + SGST)")),
                  DropdownMenuItem(value: "IGST", child: Text("IGST (18%)")),
                ],
                onChanged: (v) => setState(() { _selectedGST = v!; _redistributeAmounts(); }),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return Colors.indigo.shade50;
                      return Colors.white;
                    }),
                    columnSpacing: 20,
                    headingTextStyle: TextStyle(fontWeight: FontWeight.w700, color: Colors.indigo.shade700, fontSize: 13),
                    columns: const [
                      DataColumn(label: Text("Sr.")),
                      DataColumn(label: Text("Material")),
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Rate")),
                      DataColumn(label: Text("Qty / Dims")),
                      DataColumn(label: Text("Amount")),
                      DataColumn(label: Text("")),
                    ],
                    rows: List.generate(_materials.length, (i) {
                      if (i >= _controllers.length || i >= _quantities.length) return const DataRow(cells: []);
                      final item = _materials[i];
                      final fields = _fieldsFor(item.material);
                      return DataRow(cells: [
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Text(item.srNo.toString(), style: TextStyle(color: Colors.indigo.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
                        )),
                        DataCell(Text(item.material, style: const TextStyle(fontWeight: FontWeight.w500))),
                        DataCell(SizedBox(width: 200, child: Text(item.materialName, style: TextStyle(color: Colors.grey.shade700)))),
                        DataCell(Text("₹${item.rate.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w500))),
                        DataCell(SizedBox(
                          width: fields.length * 88.0,
                          child: Row(
                            children: fields.map((field) {
                              final ctrl = _controllers[i][field];
                              if (ctrl == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: ctrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: field,
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.indigo.shade400)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      labelStyle: const TextStyle(fontSize: 11),
                                    ),
                                    onChanged: (_) => _updateQuantity(i),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )),
                        DataCell(Text("₹${(item.rate * _quantities[i]).toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green))),
                        DataCell(IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                          onPressed: () => _removeItem(i),
                          tooltip: "Remove",
                        )),
                      ]);
                    }),
                  ),
                ),
              ),
            ),

            if (_selectedGST != "No GST")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    children: [
                      _summaryRow("Sub Total", "₹${_totalAmount.toStringAsFixed(2)}", Colors.grey.shade700),
                      Divider(color: Colors.blue.shade100, height: 20),
                      if (_selectedGST == "GST") ...[
                        _summaryRow("CGST (9%)", "₹${_cgstAmount.toStringAsFixed(2)}", Colors.blueGrey),
                        const SizedBox(height: 6),
                        _summaryRow("SGST (9%)", "₹${_sgstAmount.toStringAsFixed(2)}", Colors.blueGrey),
                      ] else
                        _summaryRow("IGST (18%)", "₹${_gstAmount.toStringAsFixed(2)}", Colors.blueGrey),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.payments_outlined, color: Colors.indigo.shade400, size: 18),
                      const SizedBox(width: 8),
                      Text("Number of Installments", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(20)),
                        child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    Slider(
                      value: _numberOfPayments, min: 1, max: 10, divisions: 9,
                      activeColor: Colors.indigo,
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
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.schedule, color: Colors.indigo.shade400, size: 18),
                    const SizedBox(width: 8),
                    const Text("Payment Schedule", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 14),
                  ...List.generate(count, (i) => Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 28, height: 28,
                              decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
                              child: Center(child: Text("${i + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                            ),
                            const SizedBox(width: 10),
                            Text("Payment ${i + 1}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.indigo.shade700)),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(
                                controller: _amountControllers[i],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: "Amount",
                                  prefixText: "₹ ",
                                  prefixIcon: Icon(Icons.currency_rupee, size: 18, color: Colors.indigo.shade400),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                onChanged: (v) { _onAmountChanged(i, v); setState(() {}); },
                                readOnly: i != 0 && count > 1 && i == count - 1,
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _paymentDates[i] ?? DateTime.now(),
                                    firstDate: DateTime(2000), lastDate: DateTime(2100),
                                    builder: (ctx, child) => Theme(
                                      data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: Colors.indigo.shade600)),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) _onDateSelected(i, picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _paymentDates[i] == null ? Colors.red.shade300 : Colors.grey.shade300,
                                      width: _paymentDates[i] == null ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(children: [
                                    Icon(Icons.calendar_today, size: 18,
                                        color: _paymentDates[i] == null ? Colors.red.shade400 : Colors.indigo.shade400),
                                    const SizedBox(width: 12),
                                    Text(
                                      _paymentDates[i] == null
                                          ? "Select Date *"
                                          : "${_paymentDates[i]!.day}/${_paymentDates[i]!.month}/${_paymentDates[i]!.year}",
                                      style: TextStyle(
                                        color: _paymentDates[i] == null ? Colors.red.shade400 : Colors.grey.shade800,
                                        fontWeight: _paymentDates[i] == null ? FontWeight.w500 : FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.arrow_drop_down,
                                        color: _paymentDates[i] == null ? Colors.red.shade300 : Colors.grey.shade400),
                                  ]),
                                ),
                              ),
                              if (_paymentDates[i] == null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 4),
                                  child: Row(children: [
                                    Icon(Icons.info_outline, size: 12, color: Colors.red.shade400),
                                    const SizedBox(width: 4),
                                    Text("Date is required", style: TextStyle(fontSize: 11, color: Colors.red.shade400)),
                                  ]),
                                ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _paymentStatuses[i],
                                decoration: InputDecoration(
                                  labelText: "Payment Status",
                                  prefixIcon: Icon(
                                    _paymentStatuses[i] == "Yes" ? Icons.check_circle_outline : _paymentStatuses[i] == "Partial" ? Icons.timelapse : Icons.cancel_outlined,
                                    size: 18,
                                    color: _paymentStatuses[i] == "Yes" ? Colors.green : _paymentStatuses[i] == "Partial" ? Colors.orange : Colors.red.shade300,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                items: const [
                                  DropdownMenuItem(value: "No", child: Text("Not Paid")),
                                  DropdownMenuItem(value: "Yes", child: Text("Paid")),
                                ],
                                onChanged: (v) => setState(() => _paymentStatuses[i] = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Sub Total", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  Text("₹${_totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ]),
                if (_selectedGST != "No GST") ...[
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("GST", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    Text("₹${_gstAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ]),
                ],
                if (widget.clientDiscount > 0) ...[
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Special Discount (${widget.clientDiscount.toStringAsFixed(0)}%)",
                        style: TextStyle(fontSize: 14, color: Colors.orange.shade700, fontWeight: FontWeight.w500)),
                    Text("- ₹${_discountAmount.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 14, color: Colors.orange.shade700, fontWeight: FontWeight.w500)),
                  ]),
                ],
                const Divider(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Grand Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  Text("₹${_finalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                ]),
                if (!_amountValid && _materials.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                    child: Row(children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      Expanded(child: Text("Installment sum must equal ₹${_finalAmount.toStringAsFixed(2)}", style: TextStyle(color: Colors.red.shade600, fontSize: 12))),
                    ]),
                  ),
                ],
                if (!_allDatesSelected && _materials.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                    child: Row(children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.red.shade400),
                      const SizedBox(width: 8),
                      Expanded(child: Text("Please select dates for all installments", style: TextStyle(color: Colors.red.shade600, fontSize: 12))),
                    ]),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: (_isSubmitting || !_amountValid || _materials.isEmpty || !_allDatesSelected) ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("Submit Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 14, color: color)),
      Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}