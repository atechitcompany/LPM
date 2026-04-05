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
                // partyName  → main title (who the job is for)
                // particularJobName → subtitle (what the job is)
                // orderBy    → third line (who ordered)
                final String partyName =
                (designerData["partyName"] ??
                    designerData["PartyName"] ??
                    "No Party")
                    .toString();
                final String jobName =
                (designerData["particularJobName"] ??
                    designerData["ParticularJobName"] ??
                    "")
                    .toString();
                final String orderBy =
                (designerData["orderBy"] ?? "").toString();

                // ── Badge ──────────────────────────────────────────────
                final String rawStatus =
                (data["status"] ?? "").toString();
                final _BadgeStyle badge =
                _resolveBadge(rawStatus, isPending);

                return InkWell(
                  // Both pending and jobs go to job-summary
                  onTap: () =>
                      context.push('/job-summary/$lpm'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
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
                        // ── Avatar ──────────────────────────────────
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ── Party + Job + OrderBy ────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              // Line 1: Party Name
                              Text(
                                partyName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (jobName.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                // Line 2: Job Name
                                Text(
                                  jobName,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (orderBy.isNotEmpty) ...[
                                const SizedBox(height: 1),
                                // Line 3: Order By
                                Text(
                                  'By: $orderBy',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // ── Status badge ─────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: badge.bgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: badge.borderColor, width: 1),
                          ),
                          child: Text(
                            badge.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: badge.textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // ── Call button (blue) ───────────────────────
                        _CircleButton(
                          color: const Color(0xFF2196F3),
                          child: const Icon(Icons.phone,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 6),

                        // ── WhatsApp button (green) ──────────────────
                        _CircleButton(
                          color: const Color(0xFF25D366),
                          child: Image.asset(
                            'assets/whatsapp-logo.png',
                            width: 16,
                            height: 16,
                            color: Colors.white,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.message,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
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

  // ── Badge resolver ────────────────────────────────────────────────────────
  _BadgeStyle _resolveBadge(String rawStatus, bool isPending) {
    if (isPending) {
      return _BadgeStyle(
        label: 'Pending',
        textColor: const Color(0xFFFF9800),
        bgColor: const Color(0xFFFFF3E0),
        borderColor: const Color(0xFFFFCC80),
      );
    }
    switch (rawStatus.toLowerCase()) {
      case 'urgent':
      case 'hot':
        return _BadgeStyle(
          label: 'Urgent',
          textColor: const Color(0xFFE53935),
          bgColor: const Color(0xFFFFEBEE),
          borderColor: const Color(0xFFEF9A9A),
        );
      case 'imp':
      case 'important':
        return _BadgeStyle(
          label: 'IMP',
          textColor: const Color(0xFFE65100),
          bgColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFCC80),
        );
      case 'today':
      case 'paid':
        return _BadgeStyle(
          label: 'Today',
          textColor: const Color(0xFF2E7D32),
          bgColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
        );
      case 'hold':
      case 'cold':
        return _BadgeStyle(
          label: 'Hold',
          textColor: const Color(0xFF1565C0),
          bgColor: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFF90CAF9),
        );
      case 'cancel':
      case 'cancelled':
        return _BadgeStyle(
          label: 'Cancel',
          textColor: const Color(0xFF616161),
          bgColor: const Color(0xFFF5F5F5),
          borderColor: const Color(0xFFBDBDBD),
        );
      case 'pending_designer_review':
        return _BadgeStyle(
          label: 'Pending',
          textColor: const Color(0xFFFF9800),
          bgColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFCC80),
        );
      case 'completed':
      default:
        return _BadgeStyle(
          label: 'Active',
          textColor: const Color(0xFFE65100),
          bgColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFCC80),
        );
    }
  }
}

// ── Small UI helpers ──────────────────────────────────────────────────────────

class _BadgeStyle {
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  const _BadgeStyle({
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
}

class _CircleButton extends StatelessWidget {
  final Color color;
  final Widget child;
  const _CircleButton({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration:
      BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}