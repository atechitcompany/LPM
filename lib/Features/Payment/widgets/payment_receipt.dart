import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentReceiptWidget extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const PaymentReceiptWidget({super.key, required this.docId, required this.data});

  @override
  State<PaymentReceiptWidget> createState() => _PaymentReceiptWidgetState();
}

class _PaymentReceiptWidgetState extends State<PaymentReceiptWidget> {
  bool _isGenerating = false;

  double get _grandTotal => (widget.data["grandTotal"] ?? 0.0).toDouble();
  double get _subTotal => (widget.data["subTotal"] ?? 0.0).toDouble();
  double get _gstAmount => (widget.data["gstAmount"] ?? 0.0).toDouble();
  double get _cgstAmount => (widget.data["cgstAmount"] ?? 0.0).toDouble();
  double get _sgstAmount => (widget.data["sgstAmount"] ?? 0.0).toDouble();
  String get _gstType => widget.data["gstType"] ?? "No GST";
  String get _client => widget.data["client"] ?? "";
  String get _job => widget.data["job"] ?? "";
  String get _lpmNumber => widget.data["lpmNumber"] ?? widget.docId;
  List<dynamic> get _installments => (widget.data["installments"] as List<dynamic>?) ?? [];
  List<dynamic> get _materials => (widget.data["materials"] as List<dynamic>?) ?? [];

  String _amountInWords(double amount) {
    final ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
      'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen',
      'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

    String convert(int n) {
      if (n == 0) return '';
      if (n < 20) return ones[n];
      if (n < 100) return '${tens[n ~/ 10]}${n % 10 != 0 ? ' ${ones[n % 10]}' : ''}';
      return '${ones[n ~/ 100]} Hundred${n % 100 != 0 ? ' ${convert(n % 100)}' : ''}';
    }

    int rupees = amount.truncate();
    int paise = ((amount - rupees) * 100).round();
    String result = '';
    if (rupees >= 10000000) { result += '${convert(rupees ~/ 10000000)} Crore '; rupees %= 10000000; }
    if (rupees >= 100000) { result += '${convert(rupees ~/ 100000)} Lakh '; rupees %= 100000; }
    if (rupees >= 1000) { result += '${convert(rupees ~/ 1000)} Thousand '; rupees %= 1000; }
    result += convert(rupees);
    result = result.trim();
    if (paise > 0) result += ' and $paise/100';
    return 'INR $result Only';
  }

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    final headerGrey = PdfColors.grey200;
    final borderColor = PdfColors.grey400;
    const cellPad = pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3);

    pw.Widget cell(String text, {bool bold = false, pw.Alignment align = pw.Alignment.centerLeft, PdfColor? bg, int flex = 1}) {
      return pw.Expanded(
        flex: flex,
        child: pw.Container(
          color: bg,
          padding: cellPad,
          child: pw.Text(text,
              style: pw.TextStyle(font: bold ? boldFont : font, fontSize: 8),
              textAlign: align == pw.Alignment.centerRight ? pw.TextAlign.right :
              align == pw.Alignment.center ? pw.TextAlign.center : pw.TextAlign.left),
        ),
      );
    }

    pw.Widget borderRow(List<pw.Widget> children, {bool topBorder = false, bool bottomBorder = true, PdfColor? bg}) {
      return pw.Container(
        decoration: pw.BoxDecoration(
          color: bg,
          border: pw.Border(
            top: topBorder ? pw.BorderSide(color: borderColor) : pw.BorderSide.none,
            bottom: bottomBorder ? pw.BorderSide(color: borderColor) : pw.BorderSide.none,
            left: pw.BorderSide(color: borderColor),
            right: pw.BorderSide(color: borderColor),
          ),
        ),
        child: pw.Row(children: children),
      );
    }

    final createdAt = widget.data["createdAt"] as Timestamp?;
    final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy').format(createdAt.toDate()) : DateFormat('dd/MM/yyyy').format(DateTime.now());

    double totalPaid = 0;
    for (final inst in _installments) {
      if (inst["status"] == "Yes") totalPaid += (inst["amount"] as num).toDouble();
    }
    final totalUnpaid = _grandTotal - totalPaid;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) => [
        pw.Center(child: pw.Text('TAX INVOICE', style: pw.TextStyle(font: boldFont, fontSize: 14))),
        pw.SizedBox(height: 6),
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor)),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Light Punch Maker', style: pw.TextStyle(font: boldFont, fontSize: 11)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Siddhartha Industrial Estate, Bldg. No.4, Gala No. F-16 & F-17,\n'
                        'New Shailesh Udyog Nagar, Opp. Nicholas Motor Garage,\n'
                        'Nr Krishna House, Sativali Road, Vasai (East) Dist. Palghar - 401-208\n'
                        'Mobile: +91 9870033033 / +91 9320033034 / 35\n'
                        'GSTIN/UIN: 27AZLPS4384D1ZY  State: Maharashtra, Code: 27\n'
                        'E-Mail: lightpunch@yahoo.com / lightpunchmaker@gmail.com\n'
                        'UDYAM-MH-17-0030022',
                    style: pw.TextStyle(font: font, fontSize: 7.5),
                  ),
                ]),
              ),
            ),
            pw.Container(width: 0.5, color: borderColor),
            pw.Expanded(
              flex: 2,
              child: pw.Column(children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                    pw.Text('Invoice No.', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                    pw.Text(_lpmNumber, style: pw.TextStyle(font: boldFont, fontSize: 8)),
                  ]),
                ),
                pw.Container(height: 0.5, color: borderColor),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                    pw.Text('Dated', style: pw.TextStyle(font: font, fontSize: 8)),
                    pw.Text(dateStr, style: pw.TextStyle(font: font, fontSize: 8)),
                  ]),
                ),
                pw.Container(height: 0.5, color: borderColor),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                    pw.Text('Payment Terms', style: pw.TextStyle(font: font, fontSize: 8)),
                    pw.Text('30 Days', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: borderColor), left: pw.BorderSide(color: borderColor), right: pw.BorderSide(color: borderColor)),
          ),
          padding: const pw.EdgeInsets.all(6),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Buyer:', style: pw.TextStyle(font: boldFont, fontSize: 8)),
            pw.SizedBox(height: 2),
            pw.Text(_client, style: pw.TextStyle(font: boldFont, fontSize: 9)),
            pw.Text('Job: $_job', style: pw.TextStyle(font: font, fontSize: 8)),
          ]),
        ),
        pw.SizedBox(height: 8),
        borderRow([
          cell('Sr', bold: true, flex: 1),
          cell('Description of Goods', bold: true, flex: 5),
          cell('Quantity', bold: true, flex: 2),
          cell('Rate', bold: true, flex: 2),
          cell('Amount', bold: true, flex: 2, align: pw.Alignment.centerRight),
        ], topBorder: true, bg: headerGrey),
        ..._materials.asMap().entries.map((e) {
          final m = e.value as Map<String, dynamic>;
          return borderRow([
            cell((m["srNo"] ?? (e.key + 1)).toString(), flex: 1),
            cell('${m["material"] ?? ""}\n${m["materialName"] ?? ""}', flex: 5),
            cell((m["quantity"] ?? 0).toStringAsFixed(2), flex: 2),
            cell('₹ ${(m["rate"] ?? 0).toStringAsFixed(2)}', flex: 2),
            cell('₹ ${(m["amount"] ?? 0).toStringAsFixed(2)}', flex: 2, align: pw.Alignment.centerRight),
          ], topBorder: false);
        }),
        borderRow([
          cell('', flex: 6),
          cell('Sub Total', bold: true, flex: 3),
          cell('₹ ${_subTotal.toStringAsFixed(2)}', bold: true, flex: 2, align: pw.Alignment.centerRight),
        ], topBorder: false),
        if (_gstType == "GST") ...[
          borderRow([
            cell('', flex: 6),
            cell('SGST (9%)', flex: 3),
            cell('₹ ${_sgstAmount.toStringAsFixed(2)}', flex: 2, align: pw.Alignment.centerRight),
          ]),
          borderRow([
            cell('', flex: 6),
            cell('CGST (9%)', flex: 3),
            cell('₹ ${_cgstAmount.toStringAsFixed(2)}', flex: 2, align: pw.Alignment.centerRight),
          ]),
        ] else if (_gstType == "IGST")
          borderRow([
            cell('', flex: 6),
            cell('IGST (18%)', flex: 3),
            cell('₹ ${_gstAmount.toStringAsFixed(2)}', flex: 2, align: pw.Alignment.centerRight),
          ]),
        borderRow([
          cell('', flex: 6),
          cell('TOTAL', bold: true, flex: 3),
          cell('₹ ${_grandTotal.toStringAsFixed(2)}', bold: true, flex: 2, align: pw.Alignment.centerRight),
        ], bg: headerGrey),
        pw.SizedBox(height: 4),
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor)),
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text('Amount Chargeable (In Words): ${_amountInWords(_grandTotal)}',
              style: pw.TextStyle(font: boldFont, fontSize: 8)),
        ),
        if (_gstType != "No GST") ...[
          pw.SizedBox(height: 8),
          borderRow([
            cell('HSN/SAC', bold: true, flex: 2),
            cell('Taxable Value', bold: true, flex: 3),
            cell('Tax Rate', bold: true, flex: 2),
            cell('Tax Amount', bold: true, flex: 2, align: pw.Alignment.centerRight),
            cell('Total Tax', bold: true, flex: 2, align: pw.Alignment.centerRight),
          ], topBorder: true, bg: headerGrey),
          borderRow([
            cell('', flex: 2),
            cell('₹ ${_subTotal.toStringAsFixed(2)}', flex: 3),
            cell('18%', flex: 2),
            cell('₹ ${_gstAmount.toStringAsFixed(2)}', flex: 2, align: pw.Alignment.centerRight),
            cell('₹ ${_gstAmount.toStringAsFixed(2)}', flex: 2, align: pw.Alignment.centerRight),
          ]),
          borderRow([
            cell('TOTAL', bold: true, flex: 2),
            cell('₹ ${_subTotal.toStringAsFixed(2)}', bold: true, flex: 3),
            cell('', flex: 2),
            cell('₹ ${_gstAmount.toStringAsFixed(2)}', bold: true, flex: 2, align: pw.Alignment.centerRight),
            cell('₹ ${_gstAmount.toStringAsFixed(2)}', bold: true, flex: 2, align: pw.Alignment.centerRight),
          ], bg: headerGrey),
        ],
        pw.SizedBox(height: 8),
        pw.Text('Payment Schedule', style: pw.TextStyle(font: boldFont, fontSize: 9)),
        pw.SizedBox(height: 4),
        borderRow([
          cell('#', bold: true, flex: 1),
          cell('Description', bold: true, flex: 3),
          cell('Status', bold: true, flex: 2),
          cell('Date', bold: true, flex: 3),
          cell('Amount', bold: true, flex: 2, align: pw.Alignment.centerRight),
        ], topBorder: true, bg: headerGrey),
        ..._installments.asMap().entries.map((e) {
          final inst = e.value as Map<String, dynamic>;
          final ts = inst["date"] as Timestamp?;
          final dStr = ts != null ? DateFormat('dd/MM/yyyy').format(ts.toDate()) : '-';
          return borderRow([
            cell((e.key + 1).toString(), flex: 1),
            cell('Payment ${e.key + 1}', flex: 3),
            cell(inst["status"] ?? "No", flex: 2),
            cell(dStr, flex: 3),
            cell('₹ ${(inst["amount"] as num).toStringAsFixed(2)}', flex: 2, align: pw.Alignment.centerRight),
          ]);
        }),
        borderRow([
          cell('', flex: 4),
          cell('TOTAL PAID', bold: true, flex: 3),
          cell('₹ ${totalPaid.toStringAsFixed(2)}', bold: true, flex: 2, align: pw.Alignment.centerRight),
        ]),
        borderRow([
          cell('', flex: 4),
          cell('UNPAID', bold: true, flex: 3),
          cell('₹ ${totalUnpaid.toStringAsFixed(2)}', bold: true, flex: 2, align: pw.Alignment.centerRight),
        ]),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor)),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text("Company's Bank Details", style: pw.TextStyle(font: boldFont, fontSize: 8)),
                  pw.SizedBox(height: 3),
                  pw.Text('Bank Name      : Kotak Mahindra Bank Ltd.', style: pw.TextStyle(font: font, fontSize: 7.5)),
                  pw.Text('A/c No.        : 0511386853', style: pw.TextStyle(font: font, fontSize: 7.5)),
                  pw.Text('Branch & IFSC  : Gokhivare Vasai & KKBK0001347', style: pw.TextStyle(font: font, fontSize: 7.5)),
                  pw.Text("Company's VAT TIN : 27021035606V", style: pw.TextStyle(font: font, fontSize: 7.5)),
                  pw.Text("Company's CST No  : 27021035606C", style: pw.TextStyle(font: font, fontSize: 7.5)),
                ]),
              ),
            ),
            pw.Container(width: 0.5, color: borderColor),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Terms and Conditions:', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    '1. If any defect in material, inform instantly. After that no claim will be entertained.\n'
                        '2. 18% interest will be charged if payment balance not paid within 30 days.',
                    style: pw.TextStyle(font: font, fontSize: 7.5),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('For Light Punch Maker\nAuthorized Signatory',
                        style: pw.TextStyle(font: boldFont, fontSize: 8),
                        textAlign: pw.TextAlign.right),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ],
    ));

    return pdf.save();
  }

  Future<void> _generateAndSaveReceipt() async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await _buildPdf();

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('receipts/$_lpmNumber.pdf');
      final uploadTask = storageRef.putData(bytes, SettableMetadata(contentType: 'application/pdf'));
      await uploadTask;
      final downloadUrl = await storageRef.getDownloadURL();

      // Save download URL to Firestore
      await FirebaseFirestore.instance.collection('receipts').doc(_lpmNumber).set({
        'lpmNumber': _lpmNumber,
        'client': _client,
        'job': _job,
        'grandTotal': _grandTotal,
        'gstType': _gstType,
        'generatedAt': FieldValue.serverTimestamp(),
        'pdfUrl': downloadUrl,
        'installments': _installments,
        'materials': _materials,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Receipt generated & saved to Storage!')),
        );
        await Printing.layoutPdf(onLayout: (_) => bytes, name: 'Receipt_$_lpmNumber.pdf');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paidCount = _installments.where((e) => e["status"] == "Yes").length;
    final allPaid = paidCount == _installments.length && _installments.isNotEmpty;
    final anyPaid = paidCount > 0;

    if (!anyPaid) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateAndSaveReceipt,
            icon: _isGenerating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.print, color: Colors.white),
            label: Text(
              _isGenerating ? 'Generating & Saving...' : 'Print & Save Receipt',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        if (allPaid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text('All $paidCount installment(s) fully paid',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
      ],
    );
  }
}