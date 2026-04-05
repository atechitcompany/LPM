class Lead {
  String id;
  String dateTime; // Follow-up Date
  String? company;
  String? leadName;
  String? nameOnReceipt;
  String? profession;
  String? whatsapp;
  String? contact2;
  String? address;
  String leadType;
  String leadStatus;
  String? leadSource;
  String? remark;

  // Financials
  double grandTotal;
  double finalAmount;
  double totalPaid;
  double pendingAmount;

  List<dynamic> payments;
  List<dynamic> callLogs;
  int callCount;

  // --- NEW: AUDIT TRAIL ---
  String? createdBy;
  String? createdOn;
  String? editedBy;
  String? editedOn;

  Lead({
    required this.id,
    required this.dateTime,
    this.company,
    this.leadName,
    this.nameOnReceipt,
    this.profession,
    this.whatsapp,
    this.contact2,
    this.address,
    required this.leadType,
    required this.leadStatus,
    this.leadSource,
    this.remark,
    this.grandTotal = 0.0,
    this.finalAmount = 0.0,
    this.totalPaid = 0.0,
    this.pendingAmount = 0.0,
    this.payments = const [],
    this.callLogs = const [],
    this.callCount = 0,
    this.createdBy,
    this.createdOn,
    this.editedBy,
    this.editedOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime,
      'company': company,
      'leadName': leadName,
      'nameOnReceipt': nameOnReceipt,
      'profession': profession,
      'whatsapp': whatsapp,
      'contact2': contact2,
      'address': address,
      'leadType': leadType,
      'leadStatus': leadStatus,
      'leadSource': leadSource,
      'remark': remark,
      'grandTotal': grandTotal,
      'finalAmount': finalAmount,
      'totalPaid': totalPaid,
      'pendingAmount': pendingAmount,
      'payments': payments,
      'callLogs': callLogs,
      'callCount': callCount,
      // Audit
      'createdBy': createdBy,
      'createdOn': createdOn,
      'editedBy': editedBy,
      'editedOn': editedOn,
    };
  }

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? '',
      dateTime: json['dateTime'] ?? '',
      company: json['company'],
      leadName: json['leadName'],
      nameOnReceipt: json['nameOnReceipt'],
      profession: json['profession'],
      whatsapp: json['whatsapp'],
      contact2: json['contact2'],
      address: json['address'],
      leadType: json['leadType'] ?? 'Client',
      leadStatus: json['leadStatus'] ?? 'Hot',
      leadSource: json['leadSource'],
      remark: json['remark'],
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
      payments: json['payments'] ?? [],
      callLogs: json['callLogs'] ?? [],
      callCount: json['callCount'] ?? 0,
      // Audit
      createdBy: json['createdBy'],
      createdOn: json['createdOn'],
      editedBy: json['editedBy'],
      editedOn: json['editedOn'],
    );
  }
}