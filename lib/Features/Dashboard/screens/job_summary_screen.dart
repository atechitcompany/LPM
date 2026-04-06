import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/session/session_manager.dart';
import 'package:provider/provider.dart';
import '../../../customer/intro/widgets/order_status_card.dart';
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<OrderDetailViewModel>().listenToJob(lpm);
          });

          final viewModel  = context.watch<OrderDetailViewModel>();
          final filesMap   = Map<String, dynamic>.from(data['files'] ?? {});

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ── HEADER ──────────────────────────────────────────
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

                /// ── ATTACHMENTS (horizontal chips row) ──────────────
                if (filesMap.isNotEmpty) ...[
                  _buildAttachmentsRow(context, filesMap),
                  const SizedBox(height: 16),
                ],

                /// ── LIVE STATUS ──────────────────────────────────────
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

                /// ── FORM DATA SECTIONS ───────────────────────────────
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

  // ====================================================================
  // ✅ ATTACHMENTS ROW — horizontal scrollable chips with file icons
  // ====================================================================
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

    if (validEntries.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── section label ──
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

        // ── horizontal scroll row ──
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
              final fileId    = fileInfo['fileId']   as String? ?? '';
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

  // ── rest of helpers ──────────────────────────────────────────────────

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
              letterSpacing: 1),
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
                      child: Text(e.key,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
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

// ======================================================================
// ✅ ATTACHMENT CHIP — compact tappable card for each file
// ======================================================================
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
    if (mimeType.startsWith('image/'))     return Icons.image_outlined;
    if (mimeType == 'application/pdf')     return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color get _iconColor {
    if (mimeType.startsWith('image/'))     return Colors.blue.shade600;
    if (mimeType == 'application/pdf')     return Colors.red.shade600;
    return Colors.grey.shade600;
  }

  Color get _bgColor {
    if (mimeType.startsWith('image/'))     return Colors.blue.shade50;
    if (mimeType == 'application/pdf')     return Colors.red.shade50;
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

            // ── big file icon ──
            Icon(_icon, color: _iconColor, size: 28),

            const SizedBox(height: 6),

            // ── field label (e.g. "Drawing") ──
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

            // ── actual file name ──
            Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}