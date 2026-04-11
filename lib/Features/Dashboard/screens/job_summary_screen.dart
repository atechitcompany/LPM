import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/session/session_manager.dart';
import 'package:provider/provider.dart';
import '../../../customer/intro/widgets/order_status_card.dart';
import '../../../customer/intro/viewmodel/order_detail_viewmodel.dart';
import 'job_summary_field_config.dart'; // ← add this import

class JobSummaryScreen extends StatelessWidget {
  final String lpm;
  const JobSummaryScreen({super.key, required this.lpm});

  static const Map<String, String> departmentEditRoute = {
    "Designer": "/jobform/designer-1",
    "AutoBending": "/jobform/autobending",
    "ManualBending": "/jobform/manualbending",
    "LaserCutting": "/jobform/laser",
    "Rubber": "/jobform/rubber",
    "Emboss": "/jobform/emboss",
  };

  /// Maps the pipeline display-name → Firestore document key.
  static const Map<String, String> departmentFirestoreKey = {
    "Designer": "designer",
    "AutoBending": "autoBending",
    "ManualBending": "manualBending",
    "LaserCutting": "laserCutting",
    "Rubber": "rubber",
    "Emboss": "emboss",
  };

  final List<String> pipeline = const [
    "Designer",
    "AutoBending",
    "ManualBending",
    "LaserCutting",
    "Rubber",
    "Emboss",
  ];

  String get _mainLpm {
    final parts = lpm.split('-');
    if (parts.length >= 5) return parts.take(4).join('-');
    return lpm;
  }

  String _prettyValue(dynamic value) {
    if (value == null) return "-";
    if (value is bool) return value ? "Yes" : "No";
    if (value is List) return value.isEmpty ? "-" : value.join(", ");
    final str = value.toString().trim();
    return str.isEmpty ? "-" : str;
  }

  /// Returns a human-friendly label for a raw Firestore field key.
  /// Falls back to inserting spaces before capital letters if no
  /// explicit override exists.
  String _fieldLabel(String key) {
    const overrides = <String, String>{
      // Designer
      "PartyName":                 "Party Name",
      "ParticularJobName":         "Particular Job Name",
      "Orderby":                   "Order By",
      "DeliveryAt":                "Delivery At",
      "PlyType":                   "Ply",
      "PlySelectedBy":             "Ply Selected By",
      "BladeSelectedBy":           "Blade Selected By",
      "CreasingSelectedBy":        "Creasing Selected By",
      "PerforationSelectedBy":     "Perforation Done By",
      "ZigZagBlade":               "Zig Zag Blade",
      "ZigZagBladeSelectedBy":     "Zig Zag Blade Selected By",
      "RubberType":                "Rubber",
      "RubberSelectedBy":          "Rubber Selected By",
      "HoleType":                  "Hole",
      "HoleSelectedBy":            "Hole Selected By",
      "StrippingType":             "Stripping",
      "CapsuleType":               "Capsule",
      "EmbossStatus":              "Emboss",
      "EmbossPcs":                 "Emboss Pcs",
      "MaleEmbossType":            "Male Emboss",
      "FemaleEmbossType":          "Female Emboss",
      "RubberFixingDone":          "Rubber Fixing Done",
      "WhiteProfileRubber":        "White Profile Rubber",
      "DesigningStatus":           "Designing Status",
      "DesignedBy":                "Designed By",
      "DesignedByTimestamp":       "Designed At",
      "SendApproval":              "Send Approval",
      // AutoBending
      "AutoBendingStatus":              "AutoBending Status",
      "AutoBendingCreatedByName":       "Done By",
      "AutoBendingCreatedByTimestamp":  "Done At",
      "AutoCreasing":                   "Auto Creasing",
      "AutoCreasingStatus":             "Auto Creasing Status",
      // ManualBending
      "ManualBendingStatus":             "ManualBending Status",
      "ManualBendingCreatedByName":      "Done By",
      "ManualBendingCreatedByTimestamp": "Done At",
      // LaserCutting
      "LaserCuttingStatus":              "Laser Cutting Status",
      "LaserCuttingCreatedByName":       "Done By",
      "LaserCuttingCreatedByTimestamp":  "Done At",
      // Rubber
      "RubberStatus":    "Rubber Status",
      "RubberCreatedBy": "Created By",
    };

    if (overrides.containsKey(key)) return overrides[key]!;

    // Auto-split camelCase → "Camel Case"
    return key.replaceAllMapped(
      RegExp(r'([A-Z])'),
          (m) => ' ${m[0]}',
    ).trim();
  }

  @override
  Widget build(BuildContext context) {
    final currentDept = SessionManager.getDepartment() ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Job Summary")),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.edit, color: Colors.black),
        onPressed: () {
          final route = departmentEditRoute[currentDept];
          if (route == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No form for $currentDept")),
            );
            return;
          }
          context.push("$route?lpm=$_mainLpm&mode=edit");
        },
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("jobs")
            .doc(_mainLpm)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.data!.exists) {
            return const Center(child: Text("Job not found"));
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final approvalStatus = data["customerApprovalStatus"];
          final changesNote    = data["customerChangesNote"];

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<OrderDetailViewModel>().listenToJob(lpm);
          });

          final viewModel = context.watch<OrderDetailViewModel>();
          final filesMap  = Map<String, dynamic>.from(data['files'] ?? {});

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── CUSTOMER CHANGES BANNER ──────────────────────────
                if (approvalStatus == "changes") ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Customer Changes",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        const SizedBox(height: 6),
                        Text(changesNote ?? "-"),
                      ],
                    ),
                  ),
                ],

                // ── HEADER ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Job Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_mainLpm),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── ATTACHMENTS ──────────────────────────────────────
                if (filesMap.isNotEmpty) ...[
                  _buildAttachmentsRow(context, filesMap),
                  const SizedBox(height: 16),
                ],

                // ── LIVE STATUS ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "LIVE JOB STATUS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OrderStatusCard(
                        stepStatus: viewModel.getStepStatus(lpm),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── FORM DATA SECTIONS ───────────────────────────────
                // For each department, read its raw Firestore data then
                // filter it through JobSummaryFieldConfig so only the
                // fields that are actually in the form are shown.
                if (departmentFirestoreKey[currentDept] != null) ...[
                  Builder(
                    builder: (context) {
                      final firestoreKey = departmentFirestoreKey[currentDept]!;

                      final rawData = Map<String, dynamic>.from(
                        data[firestoreKey]?["data"] ?? {},
                      );

                      final filteredData =
                      JobSummaryFieldConfig.filter(firestoreKey, rawData);

                      if (filteredData.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("$currentDept Details"),
                          _infoSection(filteredData),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ],

              ],
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ATTACHMENTS ROW
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildAttachmentsRow(
      BuildContext context, Map<String, dynamic> filesMap) {
    const fieldLabels = {
      'DrawingAttachment': 'Drawing',
      'RubberReport':      'Rubber Report',
      'PunchReport':       'Punch Report',
    };

    final validEntries = filesMap.entries.where((e) {
      final info = e.value as Map<String, dynamic>?;
      return info != null && (info['fileId'] ?? '').toString().isNotEmpty;
    }).toList();

    if (validEntries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(Icons.attach_file, size: 15, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              Text(
                "ATTACHMENTS  •  ${validEntries.length} file${validEntries.length > 1 ? 's' : ''}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: validEntries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final entry     = validEntries[i];
              final fieldName = entry.key;
              final fileInfo  = Map<String, dynamic>.from(entry.value);
              final fileName  = fileInfo['fileName'] as String? ?? fieldName;
              final mimeType  = fileInfo['mimeType'] as String? ?? '';
              final viewUrl   = fileInfo['viewUrl']  as String? ?? '';
              final label     = fieldLabels[fieldName] ?? fieldName;

              return _AttachmentChip(
                label:    label,
                fileName: fileName,
                mimeType: mimeType,
                viewUrl:  viewUrl,
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          t,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54),
        ),
      ),
    );
  }

  /// Renders a list of key→value rows using human-friendly labels.
  Widget _infoSection(Map<String, dynamic> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "INFORMATION",
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        ...data.entries.map((e) {
          final label       = _fieldLabel(e.key);
          final displayValue = _prettyValue(e.value);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        label,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        displayValue,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: displayValue == "-"
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade300, height: 1),
            ],
          );
        }).toList(),
      ],
    );
  }
}

// ============================================================================
// ATTACHMENT CHIP
// ============================================================================
class _AttachmentChip extends StatelessWidget {
  final String label;
  final String fileName;
  final String mimeType;
  final String viewUrl;

  const _AttachmentChip({
    required this.label,
    required this.fileName,
    required this.mimeType,
    required this.viewUrl,
  });

  IconData get _icon {
    if (mimeType.startsWith('image/'))   return Icons.image_outlined;
    if (mimeType == 'application/pdf')   return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color get _iconColor {
    if (mimeType.startsWith('image/'))   return Colors.blue.shade600;
    if (mimeType == 'application/pdf')   return Colors.red.shade600;
    return Colors.grey.shade600;
  }

  Color get _bgColor {
    if (mimeType.startsWith('image/'))   return Colors.blue.shade50;
    if (mimeType == 'application/pdf')   return Colors.red.shade50;
    return Colors.grey.shade100;
  }

  Future<void> _open() async {
    if (viewUrl.isEmpty) return;
    final uri = Uri.parse(viewUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _iconColor.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, color: _iconColor, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}