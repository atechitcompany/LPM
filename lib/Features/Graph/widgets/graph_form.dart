
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

String normalizeLocation(String text) {
  text = text.trim();
  if (text.isEmpty) return text;
  text = text.toLowerCase();
  return text[0].toUpperCase() + text.substring(1);
}

/// -------------------- MODEL --------------------
class TaskEntry {
  final String name;
  final String surname;
  final String location;
  final String work;
  final String priority;
  final String status; // "Pending" or "Done"
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskEntry({
    required this.name,
    required this.surname,
    required this.location,
    required this.work,
    required this.priority,
    required this.status,
    this.deadline,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskEntry copyWith({
    String? name,
    String? surname,
    String? location,
    String? work,
    String? priority,
    String? status,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskEntry(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      location: location ?? this.location,
      work: work ?? this.work,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "surname": surname,
    "location": location,
    "work": work,
    "priority": priority,
    "status": status,
    "deadline": deadline?.toIso8601String(),
    "createdAt": createdAt.toIso8601String(),
    "completedAt": completedAt?.toIso8601String(),
  };

  static TaskEntry fromJson(Map<String, dynamic> j) => TaskEntry(
    name: j["name"] ?? "",
    surname: j["surname"] ?? "",
    location: normalizeLocation(j["location"] ?? ""),
    work: j["work"] ?? "",
    priority: j["priority"] ?? "",
    status: j["status"] ?? "Pending",
    deadline: j["deadline"] == null ? null : DateTime.parse(j["deadline"]),
    createdAt: DateTime.parse(j["createdAt"]),
    completedAt: j["completedAt"] == null ? null : DateTime.parse(j["completedAt"]),
  );
}

/// -------------------- FORM PAGE --------------------
class GraphFormPage extends StatefulWidget {
  const GraphFormPage({super.key});

  @override
  State<GraphFormPage> createState() => _GraphFormPageState();
}

class _GraphFormPageState extends State<GraphFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _workController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController(text: "Select deadline");

  final List<String> _priorities = ["Today", "Urgent", "Tomorrow", "Later"];
  String _selectedPriority = "Today";

  final List<String> _workPresets = const [
    "Loading",
    "Unloading",
    "Packing",
    "Delivery",
    "Office",
    "Cleaning",
    "Other",
  ];

  final List<String> _locationOptions = const ["Home", "Office"];
  String? _selectedLocation;

  DateTime? _deadline;

  final List<TaskEntry> _entries = [];
  static const _storageKey = "task_entries_v1";

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEntries();
  }

  Future<void> _loadSavedEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey) ?? [];
    final decoded = list.map((e) => TaskEntry.fromJson(json.decode(e))).toList();
    setState(() {
      _entries.clear();
      _entries.addAll(decoded);
    });
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _entries.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      initialDate: _deadline ?? now,
    );

    if (picked != null) {
      setState(() {
        _deadline = picked;
        _deadlineController.text = DateFormat("dd MMM yyyy").format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please choose deadline")));
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select location")));
      return;
    }

    final entry = TaskEntry(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      location: _selectedLocation!,
      work: _workController.text.trim(),
      priority: _selectedPriority,
      status: "Pending",
      deadline: _deadline,
      completedAt: null,
    );

    setState(() => _isSaving = true);

    try {
      // Save to Firestore
      await FirebaseFirestore.instance.collection("tasks").add({
        ...entry.toJson(),
        "createdAtServer": FieldValue.serverTimestamp(),
      });

      // Save locally for graphs/tasks
      _entries.add(entry);
      await _saveEntries();

      _resetFormFields();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Task saved successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save task. Try again.")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetFormFields() {
    _nameController.clear();
    _surnameController.clear();
    _workController.clear();
    _deadlineController.text = "Select deadline";
    _selectedPriority = "Today";
    _selectedLocation = null;
    _deadline = null;
    setState(() {});
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerColor = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Task Planner"),
        backgroundColor: headerColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            tooltip: "Tasks list",
            onPressed: () => context.push('/tasks'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: "View graphs",
            onPressed: () => context.push('/graphs'),
          ),
        ],

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.assignment, color: headerColor, size: 26),
                          SizedBox(width: 10),
                          Text(
                            "New Task Entry",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: headerColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(label: "Employee Name", icon: Icons.person),
                        validator: (v) => v!.trim().isEmpty ? "Enter employee name" : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _surnameController,
                        decoration: _inputDecoration(label: "Employee Surname", icon: Icons.badge_outlined),
                        validator: (v) => v!.trim().isEmpty ? "Enter surname" : null,
                      ),
                      const SizedBox(height: 18),
                      const Text("Work (this will be used in graphs)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _workPresets.map((w) {
                          return ActionChip(label: Text(w), onPressed: () => setState(() => _workController.text = w));
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _workController,
                        decoration: _inputDecoration(label: "Work type / task", icon: Icons.work_outline),
                        validator: (v) => v!.trim().isEmpty ? "Enter work" : null,
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        decoration: _inputDecoration(label: "Location", icon: Icons.location_on_outlined),
                        items: _locationOptions.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                        onChanged: (v) => setState(() => _selectedLocation = v),
                        validator: (v) => v == null ? "Select location" : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: _inputDecoration(label: "Priority", icon: Icons.flag_outlined),
                        items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) => setState(() => _selectedPriority = v!),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _pickDeadline,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _deadlineController,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                            decoration: _inputDecoration(label: "Deadline", icon: Icons.calendar_month),
                            validator: (_) => _deadline == null ? "Select deadline" : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: headerColor,
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text("SUBMIT", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(child: Text("All new tasks start as Pending. Mark Done from the Tasks page.", style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
