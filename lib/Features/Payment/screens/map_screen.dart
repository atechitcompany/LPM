import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Map_Screen extends StatefulWidget {
  const Map_Screen({super.key});

  @override
  State<Map_Screen> createState() => _Map_ScreenState();
}

class _Map_ScreenState extends State<Map_Screen> {
  final TextEditingController _taskCtrl = TextEditingController();
  final CollectionReference _todoRef = FirebaseFirestore.instance.collection('todos');

  // --- ADD TASK FUNCTION ---
  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Task"),
        content: TextField(
          controller: _taskCtrl,
          decoration: const InputDecoration(hintText: "What to do?"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_taskCtrl.text.isNotEmpty) {
                _todoRef.add({
                  'task': _taskCtrl.text.trim(),
                  'isDone': false,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                _taskCtrl.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  // --- TOGGLE DONE ---
  void _toggleTask(String id, bool currentStatus) {
    _todoRef.doc(id).update({'isDone': !currentStatus});
  }

  // --- DELETE TASK ---
  void _deleteTask(String id) {
    _todoRef.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.blueAccent.withOpacity(0.1),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Action Plan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Daily MAP", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _todoRef.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final tasks = snapshot.data!.docs;

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        const Text("No tasks yet. Relax!", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final data = tasks[index].data() as Map<String, dynamic>;
                    final id = tasks[index].id;
                    final isDone = data['isDone'] ?? false;

                    return Card(
                      elevation: 0,
                      color: isDone ? Colors.grey[100] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: isDone,
                          activeColor: Colors.green,
                          onChanged: (val) => _toggleTask(id, isDone),
                        ),
                        title: Text(
                          data['task'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteTask(id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Task", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}