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
                final _DeptPillStyle deptPill =
                _resolveDeptPillStyle(currentDept);

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
                          shouldPulse: priority.shouldPulse,
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

                        // ── Right side: Dept pill + actions ─────────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Department pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: deptPill.bgColor,
                                borderRadius:
                                BorderRadius.circular(14),
                                border: Border.all(
                                    color: deptPill.borderColor,
                                    width: 1),
                              ),
                              child: Text(
                                currentDept,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: deptPill.textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Action buttons row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Call (outlined blue)
                                _OutlinedCircleButton(
                                  color: const Color(0xFF2196F3),
                                  icon: Icons.phone,
                                  onTap: () {
                                    // Call action placeholder
                                  },
                                ),
                                const SizedBox(width: 8),

                                // WhatsApp (outlined green)
                                _OutlinedCircleButton(
                                  color: const Color(0xFF25D366),
                                  iconWidget: Image.asset(
                                    'assets/whatsapp-logo.png',
                                    width: 16,
                                    height: 16,
                                    color: const Color(0xFF25D366),
                                    errorBuilder: (ctx, err, st) =>
                                    const Icon(
                                      Icons.message,
                                      color: Color(0xFF25D366),
                                      size: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    // WhatsApp action placeholder
                                  },
                                ),
                              ],
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
        shouldPulse: true,
      );
    }
    if (normalized == 'important' ||
        normalized == 'imp' ||
        normalized == 'high') {
      return const _PriorityStyle(
        label: 'IMP',
        bgColor: Color(0xFFFFF8E1),
        textColor: Color(0xFFE65100),
        shouldPulse: false,
      );
    }
    if (normalized == 'normal' || normalized == 'medium') {
      return const _PriorityStyle(
        label: 'NRM',
        bgColor: Color(0xFFE8F5E9),
        textColor: Color(0xFF388E3C),
        shouldPulse: false,
      );
    }
    if (normalized == 'low') {
      return const _PriorityStyle(
        label: 'LOW',
        bgColor: Color(0xFFE3F2FD),
        textColor: Color(0xFF1565C0),
        shouldPulse: false,
      );
    }
    // Unknown / empty
    return _PriorityStyle(
      label: '—',
      bgColor: Colors.grey.shade100,
      textColor: Colors.grey.shade500,
      shouldPulse: false,
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

  // ── Department pill style (color-coded) ────────────────────────────────────
  _DeptPillStyle _resolveDeptPillStyle(String dept) {
    final normalized = dept.trim().toLowerCase();

    // Color-code based on department name dynamically
    if (normalized.contains("design")) {
      return const _DeptPillStyle(
        textColor: Color(0xFF1565C0),
        bgColor: Color(0xFFE3F2FD),
        borderColor: Color(0xFF90CAF9),
      );
    }
    if (normalized.contains("auto") || normalized.contains("bending")) {
      return const _DeptPillStyle(
        textColor: Color(0xFFE65100),
        bgColor: Color(0xFFFFF3E0),
        borderColor: Color(0xFFFFCC80),
      );
    }
    if (normalized.contains("laser") || normalized.contains("cut")) {
      return const _DeptPillStyle(
        textColor: Color(0xFF6A1B9A),
        bgColor: Color(0xFFF3E5F5),
        borderColor: Color(0xFFCE93D8),
      );
    }
    if (normalized.contains("manual")) {
      return const _DeptPillStyle(
        textColor: Color(0xFF00695C),
        bgColor: Color(0xFFE0F2F1),
        borderColor: Color(0xFF80CBC4),
      );
    }
    if (normalized.contains("rubber")) {
      return const _DeptPillStyle(
        textColor: Color(0xFF4E342E),
        bgColor: Color(0xFFEFEBE9),
        borderColor: Color(0xFFBCAAA4),
      );
    }
    if (normalized.contains("emboss")) {
      return const _DeptPillStyle(
        textColor: Color(0xFF283593),
        bgColor: Color(0xFFE8EAF6),
        borderColor: Color(0xFF9FA8DA),
      );
    }
    if (normalized.contains("account")) {
      return const _DeptPillStyle(
        textColor: Color(0xFF2E7D32),
        bgColor: Color(0xFFE8F5E9),
        borderColor: Color(0xFFA5D6A7),
      );
    }
    if (normalized.contains("deliver") || normalized.contains("dispatch")) {
      return const _DeptPillStyle(
        textColor: Color(0xFF00838F),
        bgColor: Color(0xFFE0F7FA),
        borderColor: Color(0xFF80DEEA),
      );
    }
    if (normalized.contains("complete")) {
      return const _DeptPillStyle(
        textColor: Color(0xFF2E7D32),
        bgColor: Color(0xFFE8F5E9),
        borderColor: Color(0xFFA5D6A7),
      );
    }

    // Default / fallback
    return const _DeptPillStyle(
      textColor: Color(0xFF616161),
      bgColor: Color(0xFFF5F5F5),
      borderColor: Color(0xFFBDBDBD),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _PriorityStyle {
  final String label;
  final Color bgColor;
  final Color textColor;
  final bool shouldPulse;
  const _PriorityStyle({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.shouldPulse,
  });
}

class _DeptPillStyle {
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  const _DeptPillStyle({
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
}

// ── Priority Circle with optional pulse animation ────────────────────────────

class _PriorityCircle extends StatefulWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final bool shouldPulse;

  const _PriorityCircle({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.shouldPulse,
  });

  @override
  State<_PriorityCircle> createState() => _PriorityCircleState();
}

class _PriorityCircleState extends State<_PriorityCircle>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.shouldPulse) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
      _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
          parent: _pulseController!,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: widget.bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: widget.textColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: widget.textColor,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );

    if (_pulseAnimation != null) {
      return AnimatedBuilder(
        animation: _pulseAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation!.value,
            child: child,
          );
        },
        child: circle,
      );
    }

    return circle;
  }
}

// ── Outlined Circle Button ───────────────────────────────────────────────────

class _OutlinedCircleButton extends StatelessWidget {
  final Color color;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onTap;

  const _OutlinedCircleButton({
    required this.color,
    this.icon,
    this.iconWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.8),
        ),
        child: Center(
          child: iconWidget ??
              Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}