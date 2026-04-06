import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/session/session_manager.dart';
import 'package:lightatech/FormComponents/FilePreviewCard.dart'; // adjust path as needed
import 'package:provider/provider.dart';
import '../../../customer/intro/widgets/order_status_card.dart';
import '../../../customer/intro/models/order_status.dart';
import '../../../customer/intro/viewmodel/order_detail_viewmodel.dart';

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

  static const Map<String, String> pipelineLabels = {
    "Designer": "Design",
    "AutoBending": "Auto",
    "ManualBending": "Manual",
    "LaserCutting": "Laser",
    "Rubber": "Rubber",
    "Emboss": "Emboss",
  };

  // ✅ Resolves to main job ID — strips "-01" if present
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
        // ✅ Always fetch using main LPM (no "-01")
        future: FirebaseFirestore.instance
            .collection("jobs")
            .doc(_mainLpm)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.data!.exists) {
            return const Center(child: Text("Job not found"));
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          // 👈 start listening to Firestore for this LPM
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<OrderDetailViewModel>().listenToJob(lpm);
          });

          final viewModel = context.watch<OrderDetailViewModel>();

          // ✅ Extract files map from the document
          final filesMap = Map<String, dynamic>.from(data['files'] ?? {});

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// ── HEADER ──
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

                const SizedBox(height: 20),

                // ── DYNAMIC PROGRESS BAR ─────────────────────────────
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
                        stepStatus: viewModel.getStepStatus(lpm), // 👈 dynamic
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── FORM DATA SECTIONS ───────────────────────────────
                ...pipeline.map((dept) {
                  final key = departmentFirestoreKey[dept];
                  final sectionData =
                  Map<String, dynamic>.from(data[key]?["data"] ?? {});
                  if (sectionData.isEmpty) return const SizedBox();
                  return Column(
                    children: [
                      _sectionTitle("$dept Details"),
                      _infoSection(sectionData),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ======================================================
  // ✅ FILES / ATTACHMENTS SECTION
  // ======================================================
  Widget _buildFilesSection(Map<String, dynamic> filesMap) {
    // Map field names to friendly display labels
    const fieldLabels = {
      'DrawingAttachment': 'Drawing',
      'RubberReport':      'Rubber Report',
      'PunchReport':       'Punch Report',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(Icons.attach_file, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              const Text(
                "ATTACHMENTS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        // One tile per uploaded file
        ...filesMap.entries.map((entry) {
          final fieldName = entry.key;
          final fileInfo  = Map<String, dynamic>.from(entry.value ?? {});

          final fileId   = fileInfo['fileId']   as String? ?? '';
          final fileName = fileInfo['fileName'] as String? ?? fieldName;
          final mimeType = fileInfo['mimeType'] as String? ?? 'application/octet-stream';
          final viewUrl  = fileInfo['viewUrl']  as String? ?? '';
          final label    = fieldLabels[fieldName] ?? fieldName;

          if (fileId.isEmpty) return const SizedBox();

          return _FileAttachmentTile(
            label:    label,
            fileName: fileName,
            mimeType: mimeType,
            fileId:   fileId,
            viewUrl:  viewUrl,
          );
        }),
      ],
    );
  }

  // ── rest of your existing helpers unchanged ──

  Widget _buildPipeline(String currentDept) {
    int currentIndex = pipeline.indexOf(currentDept);

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(pipeline.length, (index) {
              final step = pipeline[index];
              final isDone    = index < currentIndex;
              final isCurrent = index == currentIndex;

              Color    color = Colors.grey.shade400;
              IconData icon  = Icons.circle;
              if (isDone)    { color = Colors.green;  icon = Icons.check; }
              if (isCurrent) { color = Colors.orange; icon = Icons.sync;  }

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index != 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index <= currentIndex
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: color,
                          child: Icon(icon, color: Colors.white, size: 16),
                        ),
                        if (index != pipeline.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index < currentIndex
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pipelineLabels[step] ?? step,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isCurrent
                            ? Colors.orange
                            : isDone
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

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
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _infoSection(Map<String, dynamic> data) {
    if (data.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "INFORMATION",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ...data.entries.map((e) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        e.key,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        _prettyValue(e.value),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: _prettyValue(e.value) == "-"
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

// ======================================================
// ✅ PRIVATE TILE WIDGET — one row per attachment
// ======================================================
class _FileAttachmentTile extends StatelessWidget {
  final String label;
  final String fileName;
  final String mimeType;
  final String fileId;
  final String viewUrl;

  const _FileAttachmentTile({
    required this.label,
    required this.fileName,
    required this.mimeType,
    required this.fileId,
    required this.viewUrl,
  });

  IconData get _icon {
    if (mimeType.startsWith('image/'))       return Icons.image;
    if (mimeType == 'application/pdf')       return Icons.picture_as_pdf;
    return Icons.insert_drive_file;
  }

  Color get _iconColor {
    if (mimeType.startsWith('image/'))       return Colors.blue;
    if (mimeType == 'application/pdf')       return Colors.red;
    return Colors.grey.shade600;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: ListTile(
        onTap: _open,                              // ✅ tap anywhere to open
        leading: CircleAvatar(
          backgroundColor: _iconColor.withOpacity(0.1),
          child: Icon(_icon, color: _iconColor, size: 22),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          fileName,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(Icons.open_in_new, color: Colors.blue.shade400, size: 20),
          onPressed: _open,                        // ✅ icon button also opens
          tooltip: 'Open in browser',
        ),
      ),
    );
  }
}