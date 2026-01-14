import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isUploading = false;
  String _statusMessage = "Ready to import data.";
  int _successCount = 0;

  Future<void> _pickAndUpload() async {
    setState(() {
      _isUploading = true;
      _statusMessage = "Picking file...";
    });

    try {
      // 1. Pick CSV File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        setState(() {
          _isUploading = false;
          _statusMessage = "No file selected.";
        });
        return;
      }

      // 2. Read File
      // Note: On Web it's bytes, on Mobile it's path
      final file = File(result.files.single.path!);
      final input = file.openRead();
      final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

      if (fields.isEmpty) {
        throw "File is empty";
      }

      // 3. Loop through rows (Skip row 0 because it's Header)
      setState(() => _statusMessage = "Uploading ${fields.length - 1} clients...");

      int count = 0;
      final batch = FirebaseFirestore.instance.batch(); // Batch for speed

      // Start loop from index 1 (skipping headers Name, Phone, etc)
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];

        // Safety check for row length
        if (row.length < 2) continue;

        // Create Lead Object
        String id = DateTime.now().millisecondsSinceEpoch.toString() + i.toString();

        // CSV Columns Mapping:
        // 0:Name, 1:Phone, 2:Company, 3:Address, 4:Status, 5:Pending
        String name = row[0].toString();
        String phone = row.length > 1 ? row[1].toString() : '';
        String company = row.length > 2 ? row[2].toString() : 'Imported';
        String address = row.length > 3 ? row[3].toString() : '';
        String status = row.length > 4 ? row[4].toString() : 'Hot';
        double pending = row.length > 5 ? double.tryParse(row[5].toString()) ?? 0.0 : 0.0;

        // Clean Phone Number
        phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
        if (phone.length > 10) phone = phone.substring(phone.length - 10);

        final lead = Lead(
          id: id,
          dateTime: _getTodayDate(),
          leadName: name,
          whatsapp: phone,
          company: company,
          address: address,
          leadStatus: status,
          leadType: 'Client',
          leadSource: 'Google Sheet',
          pendingAmount: pending,
          finalAmount: pending, // Assuming final deal is equal to pending for old data
          remark: 'Imported from old data',
        );

        // Add to batch
        final docRef = FirebaseFirestore.instance.collection('leads').doc(id);
        batch.set(docRef, lead.toJson());

        count++;

        // Commit every 400 records (Firebase limit is 500)
        if (count % 400 == 0) {
          await batch.commit();
        }
      }

      // Final commit
      await batch.commit();

      setState(() {
        _isUploading = false;
        _successCount = count;
        _statusMessage = "Successfully imported $count clients!";
      });

    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = "Error: $e";
      });
    }
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}, 12:00 PM';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Import Data")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Import Google Sheet Data",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Make sure your CSV has these columns in order:\nName | Phone | Company | Address | Status | Pending",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              if (_isUploading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _pickAndUpload,
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Pick CSV File"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusMessage.contains("Error") ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}