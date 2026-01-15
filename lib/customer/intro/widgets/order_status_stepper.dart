import 'package:flutter/material.dart';

class OrderStatusTimeline extends StatelessWidget {
  final int currentStep;

  const OrderStatusTimeline({
    super.key,
    required this.currentStep,
  });

  static const _steps = [
    'Designing',
    'Laser Cut',
    'AutoBending ',
    'Manual ',
    '       Delivery',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check the status below',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            /// TIMELINE
            Row(
              children: List.generate(_steps.length, (index) {
                final isCompleted = index < currentStep;
                final isActive = index == currentStep;
                final isLast = index == _steps.length - 1;

                Color dotColor;
                if (isCompleted) {
                  dotColor = Colors.blue;
                } else if (isActive) {
                  dotColor = isLast ? Colors.green : Colors.blue;
                } else {
                  dotColor = Colors.grey.shade300;
                }

                return Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (index != 0)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isCompleted
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                              ),
                            ),

                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                            child: isCompleted
                                ? const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            )
                                : null,
                          ),

                          if (!isLast)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: index < currentStep
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _steps[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isCompleted || isActive
                              ? (isLast && isActive
                              ? Colors.green
                              : Colors.blue)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.center,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                onPressed: () {},
                child: const Text(
                  'See all updates',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
