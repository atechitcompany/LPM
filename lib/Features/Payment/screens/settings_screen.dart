import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('company_name') ?? '';
      _addressCtrl.text = prefs.getString('company_address') ?? '';
      _phoneCtrl.text = prefs.getString('company_phone') ?? '';
      _emailCtrl.text = prefs.getString('company_email') ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_name', _nameCtrl.text);
    await prefs.setString('company_address', _addressCtrl.text);
    await prefs.setString('company_phone', _phoneCtrl.text);
    await prefs.setString('company_email', _emailCtrl.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company Settings")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Company Name", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: "Address", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveSettings, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text("SAVE SETTINGS"))),
          ],
        ),
      ),
    );
  }
}