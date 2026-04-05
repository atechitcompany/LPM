class UserModel {
  String id;
  String name;
  String email;
  String role; // 'Admin' or 'Employee'

  // --- PERMISSIONS (Ha/Na) ---
  bool canAddLead;
  bool canEditLead;
  bool canDeleteLead;
  bool canViewReports;

  // --- COLUMN VISIBILITY (Kya dikhega) ---
  List<String> visibleColumns; // e.g., ['phone', 'address']

  // --- EDITABLE COLUMNS (Kya badal sakta hai) ---
  List<String> editableColumns; // e.g., ['status', 'remark']

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.canAddLead = false,
    this.canEditLead = false,
    this.canDeleteLead = false,
    this.canViewReports = false,
    required this.visibleColumns,
    required this.editableColumns,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'canAddLead': canAddLead,
      'canEditLead': canEditLead,
      'canDeleteLead': canDeleteLead,
      'canViewReports': canViewReports,
      'visibleColumns': visibleColumns,
      'editableColumns': editableColumns,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Employee',
      canAddLead: json['canAddLead'] ?? false,
      canEditLead: json['canEditLead'] ?? false,
      canDeleteLead: json['canDeleteLead'] ?? false,
      canViewReports: json['canViewReports'] ?? false,
      visibleColumns: List<String>.from(json['visibleColumns'] ?? []),
      editableColumns: List<String>.from(json['editableColumns'] ?? []),
    );
  }
}