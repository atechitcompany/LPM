import 'package:flutter/material.dart';
import '../models/order_status.dart';

class OrderStatusCard extends StatelessWidget {
  final Map<OrderStatus, bool> stepStatus;

  const OrderStatusCard({
    super.key,
    required this.stepStatus,
  });

  static const List<OrderStatus> _steps = [
    OrderStatus.designing,
    OrderStatus.laserCutting,
    OrderStatus.autoBending,
    OrderStatus.manualBending,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🔹 LINE + DOTS
        SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// ✅ ONE CONTINUOUS LINE
              /// 🔹 PROGRESS LINE (blue till current, grey after)
              Positioned(
                left: 0,
                right: 0,
                child: Row(
                  children: List.generate(_steps.length - 1, (index) {
                    final isLineActive =
                        stepStatus[_steps[index]] == true; // completed till here

                    return Expanded(
                      child: Container(
                        height: 5,
                        color: isLineActive ? Colors.blue : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ),

              /// ✅ DOTS ON TOP OF LINE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _steps.map((step) {
                  final isCompleted = stepStatus[step] == true;
                  final isCurrent = _isCurrentStep(step);
                  final isLast = step == OrderStatus.delivered;

                  return _buildDot(
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isLastStep: isLast,
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// 🔹 LABELS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _steps.map((step) {
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

  /// 🔵 DOT LOGIC (exactly as you wanted)
  Widget _buildDot({
    required bool isCompleted,
    required bool isCurrent,
    required bool isLastStep,
  }) {
    double size = 20;
    Color color = Colors.grey;

    if (isCurrent) {
      size = 28; // 👈 bigger current step
      color = Colors.blue;
    } else if (isCompleted) {
      color = isLastStep ? Colors.green : Colors.blue;
      if(color==Colors.green){
        size=30;
      }
    }


    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: isCompleted && !isCurrent
          ? const Icon(
        Icons.check,
        size: 18,
        color: Colors.white,
      )
          : null,
    );
  }

  /// 🔍 CURRENT STEP = first false after a true
  bool _isCurrentStep(OrderStatus step) {
    final index = _steps.indexOf(step);
    if (index == 0) return stepStatus[step] == false;
    return stepStatus[_steps[index - 1]] == true &&
        stepStatus[step] == false;
  }

  /// 🏷️ LABELS
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
