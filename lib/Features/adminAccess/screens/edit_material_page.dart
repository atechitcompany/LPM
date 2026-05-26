import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMaterialPage extends StatefulWidget {
  const EditMaterialPage({super.key});

  @override
  State<EditMaterialPage> createState() => _EditMaterialPageState();
}

class _EditMaterialPageState extends State<EditMaterialPage> {
  final _col = FirebaseFirestore.instance.collection('materials');

  final List<String> _materialTypes = ['Ply', 'Rubber'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Material')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Material'),
                onPressed: () => _openForm(context),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Materials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _col.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No materials added yet.'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      return Card(
                        child: ListTile(
                          title: Text(doc['name']),
                          subtitle: Text('Rate: ₹${doc['rate']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openForm(context, doc: doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _col.doc(doc.id).delete(),
                              ),
                            ],
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
      ),
    );
  }

  void _openForm(BuildContext context, {DocumentSnapshot? doc}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditMaterialPage(doc: doc, materialTypes: _materialTypes),
      ),
    );
  }
}

// ── Add / Edit Page ────────────────────────────────────────────────────────

class AddEditMaterialPage extends StatefulWidget {
  final DocumentSnapshot? doc;
  final List<String> materialTypes;

  const AddEditMaterialPage({super.key, this.doc, required this.materialTypes});

  @override
  State<AddEditMaterialPage> createState() => _AddEditMaterialPageState();
}

class _AddEditMaterialPageState extends State<AddEditMaterialPage> {
  final _col = FirebaseFirestore.instance.collection('materials');
  final _rateController = TextEditingController();
  String? _selectedMaterial;

  @override
  void initState() {
    super.initState();
    if (widget.doc != null) {
      _selectedMaterial = widget.doc!['name'];
      _rateController.text = widget.doc!['rate'].toString();
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedMaterial == null || _rateController.text.isEmpty) return;
    final data = {
      'name': _selectedMaterial,
      'rate': double.tryParse(_rateController.text) ?? 0,
    };
    if (widget.doc != null) {
      await _col.doc(widget.doc!.id).update(data);
    } else {
      await _col.add(data);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.doc != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Material' : 'Add New Material')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Material', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMaterial,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Choose a material'),
              items: widget.materialTypes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedMaterial = val),
            ),
            const SizedBox(height: 16),
            const Text('Rate (₹)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter rate'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}