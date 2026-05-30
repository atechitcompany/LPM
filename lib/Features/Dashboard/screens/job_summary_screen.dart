import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/session/session_manager.dart';
import 'package:provider/provider.dart';
import '../../../customer/intro/widgets/order_status_card.dart';
import '../../../customer/intro/viewmodel/order_detail_viewmodel.dart';
import 'job_summary_field_config.dart';
import 'package:intl/intl.dart';

class JobSummaryScreen extends StatefulWidget {

  final String lpm;
  const JobSummaryScreen({super.key, required this.lpm});

  static const Map<String, String> departmentEditRoute = {
    "Designer": "/jobform/designer-1",
    "AutoBending": "/jobform/autobending",
    "ManualBending": "/jobform/manualbending",
    "LaserCutting": "/jobform/laser",
    "Lasercut": "/jobform/laser",
    "Rubber": "/jobform/rubber",
    "Emboss": "/jobform/emboss",
  };

  static const Map<String, String> departmentFirestoreKey = {
    "Designer": "designer",
    "AutoBending": "autoBending",
    "ManualBending": "manualBending",
    "LaserCutting": "laserCutting",
    "Lasercut": "laserCutting",
    "Rubber": "rubber",
    "Emboss": "emboss",
  };

  @override
  State<JobSummaryScreen> createState() => _JobSummaryScreenState();
}

class _JobSummaryScreenState extends State<JobSummaryScreen> {
  late Future<DocumentSnapshot> _jobFuture;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<OrderDetailViewModel>().listenToJob(widget.lpm);
    });

    _jobFuture = FirebaseFirestore.instance
        .collection("jobs")
        .doc(widget.lpm)
        .get(const GetOptions(source: Source.cache))
        .then((snap) {
      if (snap.exists) return snap;
      return FirebaseFirestore.instance
          .collection("jobs")
          .doc(widget.lpm)
          .get(const GetOptions(source: Source.server));
    });
  }
  final List<String> pipeline = const [
    "Designer",
    "AutoBending",
    "ManualBending",
    "LaserCutting",
    "Rubber",
    "Emboss",
  ];

  String get _mainLpm {
    final parts = widget.lpm.split('-');
    if (parts.length >= 5) return parts.take(4).join('-');
    return widget.lpm;
  }

  String _prettyValue(dynamic value) {
    if (value == null) return "-";
    if (value is bool) return value ? "Yes" : "No";
    if (value is List) return value.isEmpty ? "-" : value.join(", ");
    final str = value.toString().trim();
    return str.isEmpty ? "-" : str;
  }

  String _fieldLabel(String key) {
    const overrides = <String, String>{
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
      "AutoBendingStatus":              "AutoBending Status",
      "AutoBendingCreatedByName":       "Done By",
      "AutoBendingCreatedByTimestamp":  "Done At",
      "AutoCreasing":                   "Auto Creasing",
      "AutoCreasingStatus":             "Auto Creasing Status",
      "ManualBendingStatus":             "ManualBending Status",
      "ManualBendingCreatedByName":      "Done By",
      "ManualBendingCreatedByTimestamp": "Done At",
      "LaserCuttingStatus":              "Laser Cutting Status",
      "LaserCuttingCreatedByName":       "Done By",
      "LaserCuttingCreatedByTimestamp":  "Done At",
      "RubberStatus":    "Rubber Status",
      "RubberCreatedBy": "Created By",
    };

    if (overrides.containsKey(key)) return overrides[key]!;

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
          final route = JobSummaryScreen.departmentEditRoute[currentDept];
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
        future: _jobFuture,
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

          final viewModel = context.watch<OrderDetailViewModel>();
          final filesMap  = Map<String, dynamic>.from(data['files'] ?? {});

          String partyName = "-";
          if (data["designer"] != null && data["designer"] is Map) {
            final Map designerSec = data["designer"];
            final Map innerData = designerSec.containsKey("data") && designerSec["data"] is Map
                ? designerSec["data"]
                : designerSec;
            partyName = innerData["Party Name"] ?? innerData["PartyName"] ?? "-";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

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

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Job Details", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_mainLpm, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (filesMap.isNotEmpty) ...[
                  _buildAttachmentsRow(context, filesMap),
                  const SizedBox(height: 16),
                ],

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
                        stepStatus: viewModel.getStepStatus(widget.lpm),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── PARTY DETAILS ────────────────────────────────────
                const Text(
                  "PARTY DETAILS",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Party Name", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(partyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (JobSummaryScreen.departmentFirestoreKey[currentDept] != null) ...[
                  Builder(
                    builder: (context) {
                      final firestoreKey = JobSummaryScreen.departmentFirestoreKey[currentDept]!;
                      final rawData = Map<String, dynamic>.from(data[firestoreKey]?["data"] ?? {});
                      final filteredData = JobSummaryFieldConfig.filter(firestoreKey, rawData);
                      if (filteredData.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$currentDept Details".toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: filteredData.entries.map((e) {
                                  final label = _fieldLabel(e.key);
                                  final displayValue = _prettyValue(e.value);
                                  final isLast = e.key == filteredData.keys.last;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Text(
                                                displayValue,
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: displayValue == "-" ? Colors.grey : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isLast) Divider(color: Colors.grey.shade300, height: 1),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ],

                // ── EDIT HISTORY LOG ─────────────────────────────────
                const SizedBox(height: 4),
                const Text(
                  "EDIT HISTORY LOG",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _buildHistoryLog(),
                const SizedBox(height: 20),

              ],
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHistoryLog() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("jobs")
          .doc(_mainLpm)
          .collection("history")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                "No edit history available for this job.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          );
        }

        final historyDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historyDocs.length,
          itemBuilder: (context, index) {
            final log = historyDocs[index].data() as Map<String, dynamic>;
            final String changedBy = log['changedBy'] ?? "Unknown User";
            final String dept = log['department'] ?? "Form Update";
            final List<dynamic> changes = log['changes'] ?? [];

            String timeString = "Unknown time";
            if (log['timestamp'] != null) {
              DateTime dt = (log['timestamp'] as Timestamp).toDate();
              timeString = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  iconColor: Colors.black87,
                  title: Text(
                    changedBy,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "$dept  •  $timeString",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.history_edu, color: Colors.blue.shade700, size: 20),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: changes.map((change) {
                          final Map c = change as Map;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['field'] ?? 'Field',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.red.shade100),
                                        ),
                                        child: Text(
                                          c['oldValue'] ?? '-',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 13,
                                            decoration: TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                        child: Text(
                                          c['newValue'] ?? '-',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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

  @override
  void dispose() {
    context.read<OrderDetailViewModel>().disposeListener(widget.lpm);
    super.dispose();
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
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not open file");
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