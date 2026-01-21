import 'package:flutter/material.dart';
import '../models/order_status.dart';

class OrderProgressBar extends StatelessWidget {
  /// Each step’s completion state
  /// true  -> completed (blue)
  /// false -> pending (grey)
  final Map<OrderStatus, bool> stepStatus;

  const OrderProgressBar({
    super.key,
    required this.stepStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = stepStatus.keys.toList();

    return Column(
      children: [
        /// DOT + LINE
        Row(
          children: List.generate(statuses.length, (index) {
            final status = statuses[index];
            final isCompleted = stepStatus[status] ?? false;
            final isLast = index == statuses.length - 1;

            return Expanded(
              child: Row(
                children: [
                  _StatusDot(isCompleted: isCompleted),

                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        /// LABELS
        Row(
          children: statuses.map((status) {
            return Expanded(
              child: Text(
                _label(status),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _label(OrderStatus status) {
    switch (status) {
      case OrderStatus.designing:
        return 'Designing';
      case OrderStatus.laserCutting:
        return 'Laser Cutting';
      case OrderStatus.autoBending:
        return 'Auto Bending';
      case OrderStatus.manualBending:
        return 'Manual Bending';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}

/// ================= DOT =================
class _StatusDot extends StatelessWidget {
  final bool isCompleted;

  const _StatusDot({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.blue : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: isCompleted
          ? const Icon(
        Icons.check,
        size: 12,
        color: Colors.white,
      )
          : null,
    );
  }
}
