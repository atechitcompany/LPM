import 'package:flutter/material.dart';
import '../models/order_status.dart';

class OrderStatusCard extends StatelessWidget {
  final Map<OrderStatus, bool> stepStatus;

  const OrderStatusCard({
    super.key,
    required this.stepStatus,
  });

  @override
  Widget build(BuildContext context) {
    // 👈 split into done and pending
    final doneSteps = stepStatus.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    final pendingSteps = stepStatus.entries
        .where((e) => e.value == false)
        .map((e) => e.key)
        .toList();

    // 👈 done steps first, then pending
    final orderedSteps = [...doneSteps, ...pendingSteps];

    return Column(
      children: [
        // 🔹 LINE + DOTS
        SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 👈 progress line
              Positioned(
                left: 0,
                right: 0,
                child: Row(
                  children: List.generate(orderedSteps.length - 1, (index) {
                    final isLineActive = stepStatus[orderedSteps[index]] == true;
                    return Expanded(
                      child: Container(
                        height: 5,
                        color: isLineActive ? Colors.blue : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ),

              // 👈 dots on top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: orderedSteps.map((step) {
                  final isCompleted = stepStatus[step] == true;
                  final isLast = step == orderedSteps.last;
                  final isLastCompleted = isLast && isCompleted;

                  return _buildDot(
                    isCompleted: isCompleted,
                    isLastCompleted: isLastCompleted,
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 🔹 LABELS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: orderedSteps.map((step) {
            return SizedBox(
              width: 60,
              child: Text(
                _label(step),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDot({
    required bool isCompleted,
    required bool isLastCompleted,
  }) {
    double size = 20;
    Color color = Colors.grey.shade300;

    if (isLastCompleted) {
      size = 30;
      color = Colors.green;
    } else if (isCompleted) {
      color = Colors.blue;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }

  String _label(OrderStatus status) {
    switch (status) {
      case OrderStatus.designing:
        return 'Designing';
      case OrderStatus.laserCutting:
        return 'Laser\nCutting';
      case OrderStatus.autoBending:
        return 'Auto\nBending';
      case OrderStatus.manualBending:
        return 'Manual\nBending';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}