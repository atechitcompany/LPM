import 'package:flutter/material.dart';
import '../models/permission_model.dart';

class PermissionSection extends StatelessWidget {
  final String title;
  final PermissionModel model;
  final Function(String key, bool value) onChanged;

  const PermissionSection({
    super.key,
    required this.title,
    required this.model,
    required this.onChanged,
  });

  Widget _checkbox(String label, bool value, String key) {
    return Column(
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(key, v!),
          visualDensity: VisualDensity.compact,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section title
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          /// View Dropdown
          DropdownButtonFormField<String>(
            value: "View",
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: "View", child: Text("View")),
              DropdownMenuItem(value: "Edit", child: Text("Edit")),
            ],
            onChanged: (_) {},
          ),

          const SizedBox(height: 12),

          /// Permissions Grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _checkbox("Read", model.read, "read"),
              _checkbox("Comment", model.comment, "comment"),
              _checkbox("Write", model.write, "write"),
              _checkbox("Edit", model.edit, "edit"),
              _checkbox("Download", model.download, "download"),
              _checkbox("Upload", model.upload, "upload"),
              _checkbox("Select All", model.selectAll, "selectAll"),
              _checkbox("Delete", model.delete, "delete"),
            ],
          ),

          const SizedBox(height: 12),

          /// Specific Permissions Dropdown
          DropdownButtonFormField<String>(
            value: "Specific Permissions",
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: "Specific Permissions",
                child: Text("Specific Permissions"),
              ),
              DropdownMenuItem(
                value: "Custom",
                child: Text("Custom"),
              ),
            ],
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}
