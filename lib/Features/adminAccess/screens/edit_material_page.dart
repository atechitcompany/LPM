import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> kCategories = [
  'Blades', 'Capsules', 'Creasings', 'Embosses',
  'Extra', 'Females Emobosse', 'Holes', 'Lasers',
  'Males Embosse', 'Perforations', 'Plys', 'Rubbers',
  'Strippings', 'Zig Zags Blades',
];

const Map<String, String> kFieldKeys = {
  'Females Emobosse': 'Females Emobosse ',
};

String _fk(String category) => kFieldKeys[category] ?? category;

class EditMaterialPage extends StatefulWidget {
  const EditMaterialPage({super.key});
  @override
  State<EditMaterialPage> createState() => _EditMaterialPageState();
}

class _EditMaterialPageState extends State<EditMaterialPage> {
  String? _selectedCategory;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Material')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Choose category'),
              items: kCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Material'),
                onPressed: _selectedCategory == null ? null : () => _openForm(context),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedCategory != null) ...[
              Text(_selectedCategory!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection(_selectedCategory!).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final fk = _fk(_selectedCategory!);
                    final docs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data[fk] ?? '').toString().toLowerCase();
                      return name.contains(_searchController.text.toLowerCase());
                    }).toList();
                    if (docs.isEmpty) return const Center(child: Text('No materials found.'));
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data() as Map<String, dynamic>;
                        final rate = data.containsKey('rate') ? data['rate'] : null;
                        return Card(
                          child: ListTile(
                            title: Text((data[fk] ?? '').toString()),
                            subtitle: Text(rate != null ? 'Rate: ₹$rate' : 'Rate: not set'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _openForm(context, doc: doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => FirebaseFirestore.instance
                                      .collection(_selectedCategory!)
                                      .doc(doc.id)
                                      .delete(),
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
            ] else
              const Expanded(child: Center(child: Text('Select a category to view materials.'))),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {DocumentSnapshot? doc}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditMaterialPage(
          doc: doc,
          category: _selectedCategory!,
          fieldKey: _fk(_selectedCategory!),
        ),
      ),
    );
  }
}

class AddEditMaterialPage extends StatefulWidget {
  final DocumentSnapshot? doc;
  final String category;
  final String fieldKey;

  const AddEditMaterialPage({super.key, this.doc, required this.category, required this.fieldKey});

  @override
  State<AddEditMaterialPage> createState() => _AddEditMaterialPageState();
}

class _AddEditMaterialPageState extends State<AddEditMaterialPage> {
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.doc != null) {
      final data = widget.doc!.data() as Map<String, dynamic>;
      _nameController.text = (data[widget.fieldKey] ?? '').toString();
      _rateController.text = data.containsKey('rate') ? data['rate'].toString() : '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    final col = FirebaseFirestore.instance.collection(widget.category);
    final data = {
      widget.fieldKey: _nameController.text.trim(),
      if (_rateController.text.isNotEmpty)
        'rate': double.tryParse(_rateController.text) ?? 0,
    };
    if (widget.doc != null) {
      await col.doc(widget.doc!.id).update(data);
    } else {
      await col.add(data);
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
            Text('Category: ${widget.category}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('Material Name', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter material name'),
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