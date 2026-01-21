import 'package:flutter/material.dart';
import '../models/order_status.dart';
import '../screens/tracking_view.dart';
import './order_progress_bar.dart';

class OrderStatusCard extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderStatusCard({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          const Text(
            'Check the status below',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          /// Progress Bar
          OrderProgressBar(currentStatus: currentStatus),

          const SizedBox(height: 12),

          /// Divider
          Divider(
            color: Colors.grey.shade300,
            height: 1,
          ),

          const SizedBox(height: 8),

          /// See all updates
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TrackingView(currentStatus: currentStatus),
                  ),
                );
              },
              child: const Text(
                'See all updates',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
