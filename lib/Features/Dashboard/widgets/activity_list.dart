import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pure UI widget.
/// Receives already-filtered [docs] from ActivityListFirestore.
/// No Firestore queries here — only rendering.
class ActivityList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final bool isPending;
  final bool isQuotation;
  final bool hasMore;
  final bool isLoadingMore;
  final ScrollController scrollController;

  const ActivityList({
    super.key,
    required this.docs,
    required this.isPending,
    required this.isQuotation,
    required this.scrollController,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (docs.isEmpty && !hasMore && !isLoadingMore) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPending
                  ? Icons.pending_actions_outlined
                  : Icons.assignment_outlined,
              size: 52,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              isPending ? "No pending forms" : "No jobs yet",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    // First load
    if (docs.isEmpty && isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ────────────────────────────────────────────
          Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 12, bottom: 6),
            child: Text(
              isPending ? "Pending Forms" : "Recent Activities",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 6),
              itemCount:
              docs.length + (hasMore || isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Bottom loader
                if (index == docs.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: isLoadingMore
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFF8D94B),
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final data =
                docs[index].data() as Map<String, dynamic>;
                final designerData =
                    data["designer"]?["data"] ?? {};
                final lpm = docs[index].id;

                // ── Display fields ─────────────────────────────────────
                final String partyName =
                (designerData["partyName"] ??
                    designerData["PartyName"] ??
                    "No Party")
                    .toString();

                // ── Priority for left circle ───────────────────────────
                final String rawPriority =
                (designerData["priority"] ??
                    designerData["Priority"] ??
                    "")
                    .toString();
                final _PriorityStyle priority =
                _resolvePriority(rawPriority);

                // ── Dynamic department pill ────────────────────────────
                final String currentDept =
                _resolveCurrentDepartment(data);
                final Color deptColor = _resolveDeptTextColor(currentDept);

                return InkWell(
                  // Both pending and jobs go to job-summary
                  onTap: () =>
                      context.push('/job-summary/$lpm'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.shade100, width: 1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Priority Circle ─────────────────────────
                        _PriorityCircle(
                          label: priority.label,
                          bgColor: priority.bgColor,
                          textColor: priority.textColor,
                        ),
                        const SizedBox(width: 14),

                        // ── LPM + Party Name ───────────────────────
                        Expanded(
                          child: Text(
                            '$lpm  -  $partyName',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              color: Color(0xFF1A3A5C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // ── Right side: Dept pill + Call + WhatsApp ──
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Department pill (transparent bg, colored text)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 110),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                                child: Text(
                                  currentDept,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: deptColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Call icon
                            GestureDetector(
                              onTap: () {
                                // Call action placeholder
                              },
                              child: SizedBox(
                                width: 34,
                                height: 34,
                                child: Center(
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF54A5D9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // WhatsApp icon
                            GestureDetector(
                              onTap: () {
                                // WhatsApp action placeholder
                              },
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/TextWhatsappLogo.png',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Priority resolver ──────────────────────────────────────────────────────
  _PriorityStyle _resolvePriority(String rawPriority) {
    final normalized = rawPriority.trim().toLowerCase();

    if (normalized == 'emergency' ||
        normalized == 'emg' ||
        normalized == 'urgent') {
      return const _PriorityStyle(
        label: 'EMG',
        bgColor: Color(0xFFFFEBEE),
        textColor: Color(0xFFE53935),
      );
    }
    if (normalized == 'important' ||
        normalized == 'imp' ||
        normalized == 'high') {
      return const _PriorityStyle(
        label: 'IMP',
        bgColor: Color(0xFFFFF8E1),
        textColor: Color(0xFFE65100),
      );
    }
    if (normalized == 'normal' || normalized == 'medium') {
      return const _PriorityStyle(
        label: 'NRM',
        bgColor: Color(0xFFE8F5E9),
        textColor: Color(0xFF388E3C),
      );
    }
    if (normalized == 'low') {
      return const _PriorityStyle(
        label: 'LOW',
        bgColor: Color(0xFFE3F2FD),
        textColor: Color(0xFF1565C0),
      );
    }
    // Unknown / empty
    return _PriorityStyle(
      label: '—',
      bgColor: Colors.grey.shade100,
      textColor: Colors.grey.shade500,
    );
  }

  // ── Department resolver (no hardcoded pipeline) ────────────────────────────
  /// Derives current active department from department sub-objects.
  /// Iterates through all department keys present in the document and finds
  /// the first one whose status is not "done", indicating it's in progress.
  String _resolveCurrentDepartment(Map<String, dynamic> data) {
    // Map of Firestore department keys to their status field and display label
    final Map<String, Map<String, String>> deptConfig = {
      "designer":      {"statusField": "DesigningStatus",       "label": "Designing"},
      "autoBending":   {"statusField": "AutoBendingStatus",     "label": "AutoBending"},
      "manualBending": {"statusField": "ManualBendingStatus",   "label": "ManualBending"},
      "laserCutting":  {"statusField": "LaserCuttingStatus",    "label": "Laser Cutting"},
      "rubber":        {"statusField": "RubberStatus",          "label": "Rubber"},
      "emboss":        {"statusField": "EmbossStatus",          "label": "Emboss"},
      "account":       {"statusField": "AccountStatus",         "label": "Account"},
      "delivery":      {"statusField": "DeliveryStatus",        "label": "Delivery"},
    };

    // Walk through departments in document order; find first non-"done"
    for (final entry in deptConfig.entries) {
      final deptData = data[entry.key];
      if (deptData == null) continue;

      final innerData = deptData is Map ? (deptData["data"] ?? {}) : {};
      if (innerData is! Map) continue;

      final status =
          (innerData[entry.value["statusField"]] ?? "").toString().trim().toLowerCase();

      // If status exists and is not done, this department is active
      if (status.isNotEmpty && status != "done") {
        return entry.value["label"]!;
      }
    }

    // Fallback: use currentDepartment field if present
    final raw = (data["currentDepartment"] ?? "").toString().trim();
    if (raw.isNotEmpty && raw != "InProgress") return raw;

    return "In Progress";
  }

  // ── Department text color ──────────────────────────────────────────────────
  Color _resolveDeptTextColor(String dept) {
    final normalized = dept.trim().toLowerCase();

    if (normalized.contains("design")) return const Color(0xFF1565C0);
    if (normalized.contains("auto") || normalized.contains("bending")) return const Color(0xFFE65100);
    if (normalized.contains("laser") || normalized.contains("cut")) return const Color(0xFF6A1B9A);
    if (normalized.contains("manual")) return const Color(0xFF00695C);
    if (normalized.contains("rubber")) return const Color(0xFF4E342E);
    if (normalized.contains("emboss")) return const Color(0xFF283593);
    if (normalized.contains("account")) return const Color(0xFF2E7D32);
    if (normalized.contains("deliver") || normalized.contains("dispatch")) return const Color(0xFF00838F);
    if (normalized.contains("complete")) return const Color(0xFF2E7D32);

    return const Color(0xFF616161);
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _PriorityStyle {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _PriorityStyle({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
}

// ── Priority Circle with optional pulse animation ────────────────────────────

class _PriorityCircle extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _PriorityCircle({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
