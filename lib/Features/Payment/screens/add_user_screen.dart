import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserScreen extends StatefulWidget {
  final String? userId;
  final Map<String, dynamic>? userData;

  const AddUserScreen({super.key, this.userId, this.userData});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String _role = 'Employee';
  bool _isLoading = false; // Loading State added

  // Permissions
  bool _canAdd = true;
  bool _canDelete = false;

  // 1. ALL COLUMNS IN YOUR FORM
  final List<String> _allColumns = [
    'Date', 'Company', 'Phone', 'Address', 'Client Type',
    'Amount', 'Discount', 'Status', 'Remark', 'Uploads'
  ];

  // 2. ALL TABS IN YOUR APP
  final List<String> _allTabs = ['Home', 'ToDo', 'Paid', 'Graph'];

  final Map<String, bool> _viewAccess = {};
  final Map<String, bool> _editAccess = {};
  final Map<String, bool> _tabAccess = {};

  @override
  void initState() {
    super.initState();

    // Default Values
    for (var col in _allColumns) {
      _viewAccess[col] = true;
      _editAccess[col] = false;
    }
    for (var tab in _allTabs) {
      _tabAccess[tab] = true;
    }

    // Load Existing Data if Editing
    if (widget.userData != null) {
      final d = widget.userData!;
      _nameCtrl.text = d['name'] ?? '';
      _emailCtrl.text = d['email'] ?? '';
      _passCtrl.text = d['password'] ?? '';
      _role = d['role'] ?? 'Employee';
      _canAdd = d['canAddLead'] ?? true;
      _canDelete = d['canDeleteLead'] ?? false;

      List<dynamic> savedVisible = d['visibleColumns'] ?? [];
      List<dynamic> savedEditable = d['editableColumns'] ?? [];
      List<dynamic> savedTabs = d['visibleTabs'] ?? [];

      for (var col in _allColumns) {
        _viewAccess[col] = savedVisible.contains(col);
        _editAccess[col] = savedEditable.contains(col);
      }
      for (var tab in _allTabs) {
        _tabAccess[tab] = savedTabs.contains(tab);
      }
    }
  }

  void _saveUser() async {
    if (_emailCtrl.text.isEmpty || _nameCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name, Email and Password required")));
      return;
    }

    setState(() => _isLoading = true); // Start Loading

    try {
      // Data Preparation
      List<String> visibleCols = _viewAccess.entries.where((e) => e.value).map((e) => e.key).toList();
      List<String> editableCols = _editAccess.entries.where((e) => e.value).map((e) => e.key).toList();
      List<String> visibleTabs = _tabAccess.entries.where((e) => e.value).map((e) => e.key).toList();

      String uid = widget.userId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final userData = {
        'id': uid,
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'password': _passCtrl.text,
        'role': _role,
        'canAddLead': _canAdd,
        'canDeleteLead': _canDelete,
        'visibleColumns': visibleCols,
        'editableColumns': editableCols,
        'visibleTabs': visibleTabs,
      };

      // Save to Firebase
      await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

      if(mounted) {
        // Success Message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Saved Successfully!"), backgroundColor: Colors.green));

        // --- FIX: GO BACK AUTOMATICALLY ---
        Navigator.pop(context);
      }

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false); // Stop Loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.userId == null ? "Create User" : "Edit User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BASIC INFO
            const Text("Login Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email ID", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: "Role", border: OutlineInputBorder()),
              items: ['Employee', 'Admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _role = v!),
            ),

            const SizedBox(height: 20),
            const Divider(thickness: 2),

            // 2. MAIN ACTIONS
            const Text("Main Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(title: const Text("Can Add New Leads?"), value: _canAdd, onChanged: (v) => setState(() => _canAdd = v)),
            SwitchListTile(title: const Text("Can Delete Data?"), value: _canDelete, activeColor: Colors.red, onChanged: (v) => setState(() => _canDelete = v)),

            const Divider(thickness: 2),

            // 3. TABS VISIBILITY
            const Text("Visible Tabs (Bottom Bar)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
            const Text("Uncheck to hide tabs from this user", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Wrap(
              spacing: 10,
              children: _allTabs.map((tab) {
                return FilterChip(
                  label: Text(tab),
                  selected: _tabAccess[tab]!,
                  onSelected: (v) => setState(() => _tabAccess[tab] = v),
                  selectedColor: Colors.purple[100],
                );
              }).toList(),
            ),

            const Divider(thickness: 2),

            // 4. COLUMN CONTROL
            const Text("Form Columns Access", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Text("Control what they See (View) and Change (Edit)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),

            // Table Header
            Row(
              children: const [
                Expanded(flex: 3, child: Text("Field Name", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Center(child: Text("View", style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text("Edit", style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
            const Divider(),

            // Table Rows
            ..._allColumns.map((col) {
              return Container(
                color: _viewAccess[col]! ? Colors.transparent : Colors.grey[200], // Grey out if hidden
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(col, style: const TextStyle(fontSize: 15))),
                    Expanded(
                        child: Checkbox(
                            value: _viewAccess[col],
                            onChanged: (v) => setState(() {
                              _viewAccess[col] = v!;
                              if(!v) _editAccess[col] = false;
                            })
                        )
                    ),
                    Expanded(
                        child: Checkbox(
                            value: _editAccess[col],
                            activeColor: Colors.orange,
                            onChanged: _viewAccess[col]! ? (v) => setState(() => _editAccess[col] = v!) : null
                        )
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            // --- SAVE BUTTON WITH LOADING ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveUser, // Disable while loading
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.userId == null ? "CREATE USER" : "UPDATE USER"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}