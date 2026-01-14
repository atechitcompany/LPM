import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class RequestAccessScreen extends StatefulWidget {
  const RequestAccessScreen({super.key});

  @override
  State<RequestAccessScreen> createState() => _RequestAccessScreenState();
}

class _RequestAccessScreenState extends State<RequestAccessScreen> {
  String _requestType = 'Column Access'; // Column Access or Tab Access
  String _permissionType = 'View'; // View or Edit
  String? _selectedItem;
  bool _isLoading = false;

  // Items to request
  final List<String> _columns = ['Phone', 'Address', 'Amount', 'Discount', 'Status', 'Remark', 'Uploads'];
  final List<String> _tabs = ['ToDo', 'Paid', 'Graph'];

  Future<void> _sendRequest() async {
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an item")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId');
      final name = prefs.getString('userName') ?? 'Unknown User';
      final email = prefs.getString('userEmail') ?? 'No Email'; // Ensure you save email in Login

      if (uid == null) throw "User ID not found";

      // Save Request to Firebase
      await FirebaseFirestore.instance.collection('access_requests').add({
        'userId': uid,
        'userName': name,
        'userEmail': email,
        'type': _requestType, // Column or Tab
        'permission': _permissionType, // View or Edit
        'item': _selectedItem, // 'Amount', 'Graph' etc.
        'status': 'Pending', // Pending, Approved, Rejected
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Sent to Admin!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Access")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What do you need access to?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 1. Request Type (Column / Tab)
            DropdownButtonFormField<String>(
              value: _requestType,
              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
              items: ['Column Access', 'Tab Access'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                setState(() {
                  _requestType = v!;
                  _selectedItem = null;
                  if(_requestType == 'Tab Access') _permissionType = 'View'; // Tabs only have View
                });
              },
            ),
            const SizedBox(height: 15),

            // 2. Permission Type (View / Edit) - Only for Columns
            if (_requestType == 'Column Access')
              DropdownButtonFormField<String>(
                value: _permissionType,
                decoration: const InputDecoration(labelText: "Permission Needed", border: OutlineInputBorder()),
                items: ['View', 'Edit'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _permissionType = v!),
              ),
            if (_requestType == 'Column Access') const SizedBox(height: 15),

            // 3. Select Item
            DropdownButtonFormField<String>(
              value: _selectedItem,
              decoration: InputDecoration(labelText: "Select ${_requestType == 'Column Access' ? 'Field' : 'Tab'}", border: const OutlineInputBorder()),
              items: (_requestType == 'Column Access' ? _columns : _tabs)
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedItem = v),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendRequest,
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryYellow, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                icon: _isLoading ? const SizedBox() : const Icon(Icons.send),
                label: _isLoading ? const CircularProgressIndicator() : const Text("SEND REQUEST"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}