import 'package:flutter/material.dart';

class AddActivityDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController companyController;
  final TextEditingController roleController;
  final String selectedStatus;
  final Function(String?) onStatusChanged;
  final VoidCallback onAdd;

  const AddActivityDialog({
    Key? key,
    required this.nameController,
    required this.companyController,
    required this.roleController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Activity'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: companyController, decoration: InputDecoration(labelText: 'Company')),
            TextField(controller: roleController, decoration: InputDecoration(labelText: 'Role')),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: ['Hot', 'Paid', 'Cold', 'Done']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onStatusChanged,
              decoration: InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: onAdd, child: Text('Add')),
      ],
    );
  }
}