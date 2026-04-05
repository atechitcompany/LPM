import 'package:flutter/material.dart';
import 'permission_model.dart';

class UserRightsViewModel extends ChangeNotifier {
  String selectedRole = "Admin";

  final Map<String, PermissionModel> permissions = {
    "Client Data": PermissionModel(),
    "Job": PermissionModel(),
    "Account": PermissionModel(),
    "Delivery": PermissionModel(),
  };

  void updateRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  void togglePermission(String section, String key, bool value) {
    final model = permissions[section]!;

    switch (key) {
      case 'read':
        model.read = value;
        break;
      case 'comment':
        model.comment = value;
        break;
      case 'write':
        model.write = value;
        break;
      case 'edit':
        model.edit = value;
        break;
      case 'download':
        model.download = value;
        break;
      case 'upload':
        model.upload = value;
        break;
      case 'selectAll':
        model.selectAll = value;
        break;
      case 'delete':
        model.delete = value;
        break;
    }

    notifyListeners();
  }

  void save() {
    debugPrint("Selected Role: $selectedRole");
    permissions.forEach((key, value) {
      debugPrint("$key => $value");
    });
  }
}
