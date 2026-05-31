import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/payment_receipt.dart';

class EditPaymentPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditPaymentPage({super.key, required this.docId, required this.data});

  @override
  State<EditPaymentPage> createState() => _EditPaymentPageState();
}

class _EditPaymentPageState extends State<EditPaymentPage> {
  late List<Map<String, dynamic>> _installments;
  late List<TextEditingController> _amountControllers;
  late List<DateTime?> _paymentDates;
  late List<String> _paymentStatuses;
  late List<bool> _isLocked;

  bool _isSubmitting = false;

  double get _grandTotal => (widget.data["grandTotal"] ?? 0.0).toDouble();

  Map<String, dynamic> get _currentData => {
    ...widget.data,
    "installments": List.generate(_amountControllers.length, (i) => {
      "installmentNumber": i + 1,
      "amount": double.tryParse(_amountControllers[i].text) ?? 0.0,
      "date": _paymentDates[i] != null ? Timestamp.fromDate(_paymentDates[i]!) : null,
      "status": _paymentStatuses[i],
    }),
  };

  @override
  void initState() {
    super.initState();
    _installments = List<Map<String, dynamic>>.from(
      (widget.data["installments"] as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
    );
    _amountControllers = _installments
        .map((e) => TextEditingController(text: (e["amount"] ?? 0.0).toStringAsFixed(2)))
        .toList();
    _paymentDates = _installments.map((e) {
      final ts = e["date"];
      return ts is Timestamp ? ts.toDate() : null;
    }).toList();
    _paymentStatuses = _installments.map((e) => (e["status"] ?? "No").toString()).toList();
    _isLocked = _installments.map((e) => e["status"] == "Yes").toList();
  }

  @override
  void dispose() {
    for (final c in _amountControllers) c.dispose();
    super.dispose();
  }

  bool get _amountValid {
    final sum = _amountControllers.fold(0.0, (a, c) => a + (double.tryParse(c.text) ?? 0.0));
    return (sum - _grandTotal).abs() < 0.01;
  }

  void _onAmountChanged(int index, String value) {
    if (_isLocked[index]) return;

    double lockedSum = 0;
    for (int i = 0; i < _amountControllers.length; i++) {
      if (_isLocked[i]) lockedSum += double.tryParse(_amountControllers[i].text) ?? 0.0;
    }

    double enteredSum = lockedSum;
    for (int i = 0; i < _amountControllers.length; i++) {
      if (!_isLocked[i] && i <= index) {
        enteredSum += (i == index) ? (double.tryParse(value) ?? 0.0) : (double.tryParse(_amountControllers[i].text) ?? 0.0);
      }
    }

    final remaining = _grandTotal - enteredSum;
    final futureUnlocked = <int>[];
    for (int i = index + 1; i < _amountControllers.length; i++) {
      if (!_isLocked[i]) futureUnlocked.add(i);
    }

    setState(() {
      if (futureUnlocked.isNotEmpty) {
        final each = (remaining / futureUnlocked.length).toStringAsFixed(2);
        for (final i in futureUnlocked) _amountControllers[i].text = each;
      }
      _autoTrimInstallments();
    });
  }

  void _autoTrimInstallments() {
    double runningSum = 0;
    int cutIndex = -1;
    for (int i = 0; i < _amountControllers.length; i++) {
      runningSum += double.tryParse(_amountControllers[i].text) ?? 0.0;
      if ((runningSum - _grandTotal).abs() < 0.01) {
        cutIndex = i;
        break;
      }
    }
    if (cutIndex != -1 && cutIndex < _amountControllers.length - 1) {
      final toRemove = <int>[];
      for (int i = cutIndex + 1; i < _amountControllers.length; i++) {
        if (!_isLocked[i]) toRemove.add(i);
      }
      for (final i in toRemove.reversed) {
        _amountControllers[i].dispose();
        _amountControllers.removeAt(i);
        _paymentDates.removeAt(i);
        _paymentStatuses.removeAt(i);
        _isLocked.removeAt(i);
        _installments.removeAt(i);
      }
    }
  }

  void _onDateSelected(int index, DateTime picked) {
    setState(() {
      _paymentDates[index] = picked;
      for (int j = index + 1; j < _amountControllers.length; j++) {
        if (!_isLocked[j]) {
          _paymentDates[j] = DateTime(picked.year, picked.month + (j - index), picked.day);
        }
      }
    });
  }

  Future<void> _savePayment() async {
    setState(() { _isSubmitting = true; });
    try {
      final updated = List.generate(_amountControllers.length, (i) => {
        "installmentNumber": i + 1,
        "amount": double.tryParse(_amountControllers[i].text) ?? 0.0,
        "date": _paymentDates[i] != null ? Timestamp.fromDate(_paymentDates[i]!) : null,
        "status": _paymentStatuses[i],
      });

      await FirebaseFirestore.instance
          .collection("payments")
          .doc(widget.docId)
          .update({"installments": updated});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Payment updated!")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _amountControllers.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Edit — ${widget.docId}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.data["client"] ?? "", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(widget.data["job"] ?? "", style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("GST: ${widget.data["gstType"] ?? "No GST"}", style: TextStyle(color: Colors.grey.shade600)),
                  Text("Grand Total: ₹ ${_grandTotal.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ]),
              ]),
            ),

            const Text("Payment Installments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...List.generate(count, (i) {
              final locked = _isLocked[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: locked ? Colors.green.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: locked ? Colors.green.shade200 : Colors.grey.shade200),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Payment ${i + 1}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (locked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                        child: const Text("Paid & Locked", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountControllers[i],
                    readOnly: locked,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => _onAmountChanged(i, v),
                    decoration: InputDecoration(
                      labelText: "Amount", prefixText: "₹ ", filled: true,
                      fillColor: locked ? Colors.green.shade50 : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: locked ? null : () async {
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
                        color: locked ? Colors.green.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: locked ? Colors.green.shade200 : Colors.grey.shade400),
                      ),
                      child: Row(children: [
                        Icon(Icons.date_range, color: locked ? Colors.green : Colors.black),
                        const SizedBox(width: 12),
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
                      labelText: "Payment Status", filled: true,
                      fillColor: locked ? Colors.green.shade50 : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: locked
                        ? [DropdownMenuItem(value: _paymentStatuses[i], child: Text(_paymentStatuses[i]))]
                        : const [
                      DropdownMenuItem(value: "No", child: Text("No")),
                      DropdownMenuItem(value: "Yes", child: Text("Yes")),
                    ],
                    onChanged: locked ? null : (v) => setState(() => _paymentStatuses[i] = v!),
                  ),
                ]),
              );
            }),

            if (!_amountValid)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Sum of installments must equal Grand Total (₹ ${_grandTotal.toStringAsFixed(2)})",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: (_isSubmitting || !_amountValid) ? null : _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),

            // Receipt widget — shows Print Receipt button when any installment is paid
            PaymentReceiptWidget(
              docId: widget.docId,
              data: _currentData,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}