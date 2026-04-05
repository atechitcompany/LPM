// graph_tasks_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/graph_form.dart' show TaskEntry;

const _storageKey = "task_entries_v1";

class GraphTasksPage extends StatefulWidget {
  const GraphTasksPage({super.key});

  @override
  State<GraphTasksPage> createState() => _GraphTasksPageState();
}

class _GraphTasksPageState extends State<GraphTasksPage> {
  List<TaskEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey) ?? [];
    final decoded = list.map((e) => TaskEntry.fromJson(json.decode(e))).toList();

    setState(() {
      _entries = decoded;
      _loading = false;
    });
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _entries.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  void _toggleStatus(int index) async {
    final old = _entries[index];

    TaskEntry updated;
    if (old.status == "Pending") {
      updated = old.copyWith(status: "Done", completedAt: DateTime.now());
    } else {
      updated = old.copyWith(status: "Pending", completedAt: null);
    }

    setState(() {
      _entries[index] = updated;
    });

    await _saveEntries();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(updated.status == "Done" ? "Marked as Done" : "Marked as Pending"), duration: const Duration(seconds: 1)),
    );
  }

  Color _statusColor(String status) {
    if (status == "Done") return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? const Center(child: Text("No tasks yet. Add from the form.", style: TextStyle(color: Colors.grey)))
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final e = _entries[index];
          final employee = "${e.name} ${e.surname}".trim();
          final deadlineStr = e.deadline == null ? "No deadline" : DateFormat("dd MMM yyyy").format(e.deadline!);
          final createdStr = DateFormat("dd MMM").format(e.createdAt);

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(e.work, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                  const SizedBox(width: 8),
                  Text(e.status, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: _statusColor(e.status))),
                ]),
                const SizedBox(height: 4),
                if (employee.isNotEmpty) Text("Employee: $employee", style: const TextStyle(fontSize: 12)),
                Text("Location: ${e.location}", style: const TextStyle(fontSize: 12)),
                Text("Deadline: $deadlineStr", style: const TextStyle(fontSize: 12)),
                Text("Created: $createdStr", style: const TextStyle(fontSize: 12)),
                if (e.status == "Done" && e.completedAt != null) Text("Completed: ${DateFormat("dd MMM yyyy").format(e.completedAt!)}", style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => _toggleStatus(index),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(110, 36)),
                      child: Text(e.status == "Pending" ? "Mark Done" : "Mark Pending", style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
              ]),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemCount: _entries.length,
      ),
    );
  }
}
