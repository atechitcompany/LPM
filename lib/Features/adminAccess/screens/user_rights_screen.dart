import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_rights_viewmodel.dart';
import '../widgets/permission_section.dart';

class UserRightsScreen extends StatelessWidget {
  UserRightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRightsViewModel(),
      child: Consumer<UserRightsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,

            /// App Bar
            appBar: AppBar(
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("User Rights",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    "for Ms.xyz",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                  onPressed: vm.save,
                  icon: const Icon(Icons.check, color: Colors.blue, size: 18),
                  label: const Text("Save",
                      style: TextStyle(color: Colors.blue)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            /// Body
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /// App Role Dropdown
                  DropdownButtonFormField<String>(
                    value: vm.selectedRole,
                    decoration: const InputDecoration(
                      labelText: "App Role",
                      border: OutlineInputBorder(),
                    ),
                    items: ["Admin", "Manager", "Staff"]
                        .map(
                          (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                        .toList(),
                    onChanged: (value) =>
                        vm.updateRole(value ?? "Admin"),
                  ),

                  const SizedBox(height: 16),

                  /// Sections
                  ...vm.permissions.entries.map(
                        (entry) => PermissionSection(
                      title: entry.key,
                      model: entry.value,
                      onChanged: (key, value) {
                        vm.togglePermission(
                          entry.key,
                          key,
                          value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
