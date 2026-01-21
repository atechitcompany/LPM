import 'package:flutter/material.dart';
import '../models/order_status.dart';
import '../screens/tracking_view.dart';
import 'order_progress_bar.dart';

class OrderStatusCard extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderStatusCard({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check the status below',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),

            OrderProgressBar(currentStatus: currentStatus),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TrackingView(currentStatus: currentStatus),
                  ),
                );
              },
              child: const Center(
                child: Text(
                  'See all updates',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
