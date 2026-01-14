import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

import '../models/lead_model.dart';
import '../core/constants.dart';

// --- PAYMENT FORM SCREEN ---
class PaymentFormScreen extends StatefulWidget {
  final String? receiptNo;
  final double grandTotal;
  final double totalPaidSoFar;
  const PaymentFormScreen({super.key, this.receiptNo, required this.grandTotal, this.totalPaidSoFar = 0.0});
  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _receiptCtrl, _grandTotalCtrl, _finalAmountCtrl, _totalPaidCtrl, _pendingCtrl, _remarkCtrl;
  bool _addGst = false;
  double _paymentAmount = 0.0, _gstAmount = 0.0, _cgst = 0.0, _sgst = 0.0;
  DateTime _paymentDate = DateTime.now();
  bool _generateBill = true;

  @override
  void initState() {
    super.initState();
    // Auto-generate Receipt No if null
    final initialReceipt = widget.receiptNo ?? 'RCPT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    _receiptCtrl = TextEditingController(text: initialReceipt);
    _grandTotalCtrl = TextEditingController(text: widget.grandTotal.toStringAsFixed(0));
    _finalAmountCtrl = TextEditingController(text: widget.grandTotal.toStringAsFixed(0));
    _totalPaidCtrl = TextEditingController(text: widget.totalPaidSoFar.toStringAsFixed(0));
    _pendingCtrl = TextEditingController(text: (widget.grandTotal - widget.totalPaidSoFar).clamp(0.0, double.infinity).toStringAsFixed(0));
    _remarkCtrl = TextEditingController(text: "Payment received via Cash/UPI"); // Default text
    _recalcFinal();
  }

  void _recalcFinal() {
    final base = double.tryParse(_grandTotalCtrl.text) ?? 0.0;
    var finalAmt = base;
    if (_addGst) finalAmt = finalAmt * 1.18;
    _finalAmountCtrl.text = finalAmt.toStringAsFixed(0);
    _gstAmount = _addGst ? (finalAmt - (finalAmt / 1.18)) : 0.0;
    _cgst = _gstAmount / 2; _sgst = _gstAmount / 2;
    setState(() {});
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    if (_paymentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter payment amount')));
      return;
    }

    Navigator.of(context).pop({
      'action': 'add',
      'amount': _paymentAmount,
      'date': '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
      'remark': _remarkCtrl.text.isEmpty ? 'Payment Received' : _remarkCtrl.text,
      'receiptNo': _receiptCtrl.text,
      'gstApplied': _addGst,
      'gstAmount': _gstAmount,
      'cgst': _cgst,
      'sgst': _sgst,
      'generateBill': _generateBill,
      'billNo': 0,
      'billDate': '',
    });
  }

  InputDecoration _deco(String label) => InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment'), actions: [TextButton(onPressed: _onSave, child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Receipt & Total Row
        Row(children: [
          Expanded(child: TextFormField(controller: _receiptCtrl, readOnly: true, decoration: _deco('Receipt No'))),
          const SizedBox(width: 10),
          Expanded(child: TextFormField(controller: _grandTotalCtrl, readOnly: true, decoration: _deco('Total Deal Value'))),
        ]),
        const SizedBox(height: 10),

        // GST Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Apply 18% GST?"), Switch(value: _addGst, onChanged: (v) {setState(() => _addGst = v); _recalcFinal();})]),
        ),
        const SizedBox(height: 10),

        // Paid & Pending Row
        Row(children: [
          Expanded(child: TextFormField(controller: _totalPaidCtrl, readOnly: true, decoration: _deco('Already Paid').copyWith(fillColor: Colors.green[50], filled: true))),
          const SizedBox(width: 10),
          Expanded(child: TextFormField(controller: _pendingCtrl, readOnly: true, decoration: _deco('Pending').copyWith(fillColor: Colors.red[50], filled: true))),
        ]),
        const SizedBox(height: 20),

        const Divider(thickness: 2),
        const SizedBox(height: 10),
        const Text("NEW PAYMENT ENTRY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
        const SizedBox(height: 15),

        // Amount Input
        TextFormField(
            decoration: _deco('Enter Amount Received *').copyWith(prefixText: '₹ ', fillColor: Colors.yellow[50], filled: true),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            onChanged: (v) => _paymentAmount = double.tryParse(v) ?? 0.0
        ),
        const SizedBox(height: 15),

        // Remark Input
        TextFormField(
          controller: _remarkCtrl,
          decoration: _deco('Remark / Description').copyWith(hintText: 'e.g. Advance Payment via GPay'),
          maxLines: 2,
        ),

        const SizedBox(height: 30),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _onSave, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryYellow, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('SAVE PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
      ]))),
    );
  }
}

// --- PROFESSIONAL PDF GENERATION LOGIC ---
Future<Uint8List> generateReceiptPdf(Lead lead, Map<String, dynamic> payment) async {
  final pdf = pw.Document();

  // Load Fonts
  final fontBold = await PdfGoogleFonts.robotoBold();
  final fontRegular = await PdfGoogleFonts.robotoRegular();

  // Prepare Data
  final receiptNo = payment['receiptNo'] ?? '000';
  final date = payment['date'] ?? '-';
  final amount = (payment['amount'] as num).toDouble();
  final remark = payment['remark'] ?? 'Payment Received';

  // Pending Calculation: Total Deal - (Already Paid + This Payment)
  // Logic Note: The 'lead.pendingAmount' in the Lead object might already be updated or not.
  // Ideally, we display the pending amount *after* this payment.
  final pending = lead.pendingAmount < 0 ? 0 : lead.pendingAmount;

  pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) {
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 1. HEADER
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("A TECH IT COMPANY", style: pw.TextStyle(font: fontBold, fontSize: 22, color: PdfColors.blue900)),
                              pw.SizedBox(height: 4),
                              pw.Text("Near Railway Station, Virar (W)", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                              pw.Text("Mumbai, Maharashtra - 401303", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                              pw.Text("Email: support@atech.com | Ph: +91 9876543210", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                            ]
                        ),
                        pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(4)),
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text("PAYMENT RECEIPT", style: pw.TextStyle(font: fontBold, fontSize: 14)),
                                  pw.Text("# $receiptNo", style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.red900)),
                                  pw.Text("Date: $date", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                                ]
                            )
                        )
                      ]
                  ),
                  pw.Divider(thickness: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 15),

                  // 2. BILL TO SECTION
                  pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(4)
                      ),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("RECEIVED FROM (Bill To):", style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey600)),
                            pw.SizedBox(height: 4),
                            pw.Text(lead.leadName?.toUpperCase() ?? "CLIENT", style: pw.TextStyle(font: fontBold, fontSize: 14)),
                            if (lead.company != null && lead.company!.isNotEmpty)
                              pw.Text(lead.company!, style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                            if (lead.address != null && lead.address!.isNotEmpty)
                              pw.Text(lead.address!, style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                            pw.Text("Phone: ${lead.whatsapp ?? '-'}", style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                          ]
                      )
                  ),
                  pw.SizedBox(height: 20),

                  // 3. PAYMENT TABLE
                  pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey400),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3), // Description
                        1: const pw.FlexColumnWidth(1), // Amount
                      },
                      children: [
                        // Header
                        pw.TableRow(
                            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                            children: [
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text("DESCRIPTION", style: pw.TextStyle(font: fontBold, fontSize: 12))
                              ),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text("AMOUNT (INR)", style: pw.TextStyle(font: fontBold, fontSize: 12), textAlign: pw.TextAlign.right)
                              ),
                            ]
                        ),
                        // Data Row
                        pw.TableRow(
                            children: [
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(12),
                                  child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text("Payment Received", style: pw.TextStyle(font: fontBold, fontSize: 12)),
                                        pw.SizedBox(height: 4),
                                        pw.Text("Note: $remark", style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                                      ]
                                  )
                              ),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(12),
                                  child: pw.Text("Rs. ${amount.toStringAsFixed(0)}", style: pw.TextStyle(font: fontBold, fontSize: 12), textAlign: pw.TextAlign.right)
                              ),
                            ]
                        ),
                      ]
                  ),

                  // 4. TOTALS
                  pw.Container(
                      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400), left: pw.BorderSide(color: PdfColors.grey400), right: pw.BorderSide(color: PdfColors.grey400))),
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text("Total Received:   Rs. ${amount.toStringAsFixed(0)}", style: pw.TextStyle(font: fontBold, fontSize: 14)),
                                  pw.SizedBox(height: 5),
                                  pw.Text("(Pending Balance:   Rs. ${pending.toStringAsFixed(0)})", style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.red)),
                                ]
                            )
                          ]
                      )
                  ),

                  pw.Spacer(),

                  // 5. FOOTER & SIGNATURE
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                          pw.Text("Terms & Conditions:", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                          pw.Text("1. Payment is non-refundable.", style: pw.TextStyle(fontSize: 8)),
                          pw.Text("2. Cheques are subject to realization.", style: pw.TextStyle(fontSize: 8)),
                        ]),
                        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                          pw.Container(width: 120, height: 1, color: PdfColors.black),
                          pw.SizedBox(height: 4),
                          pw.Text("Authorized Signature", style: pw.TextStyle(font: fontBold, fontSize: 10)),
                          pw.Text("A TECH IT COMPANY", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                        ])
                      ]
                  ),
                  pw.SizedBox(height: 20),
                  pw.Center(child: pw.Text("Thank you for your business!", style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.grey600)))
                ]
            );
          }
      )
  );
  return pdf.save();
}

// --- PREVIEW SCREEN ---
class ReceiptPreviewScreen extends StatelessWidget {
  final Lead lead; final Map<String, dynamic> payment;
  const ReceiptPreviewScreen({super.key, required this.lead, required this.payment});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Receipt Preview')), body: PdfPreview(build: (f) => generateReceiptPdf(lead, payment)));
}