import 'package:flutter/material.dart';
import '../models/order_status.dart';

class TrackingView extends StatelessWidget {
  final OrderStatus currentStatus;

  const TrackingView({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = OrderStatus.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking View'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isCompleted = status.index <= currentStatus.index;

          return ListTile(
            leading: _StatusIcon(isCompleted: isCompleted),
            title: Text(
              _title(status),
              style: TextStyle(
                fontWeight:
                isCompleted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: Text(_description(status)),
          );
        },
      ),
    );
  }

  String _title(OrderStatus status) {
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

  String _description(OrderStatus status) {
    switch (status) {
      case OrderStatus.designing:
        return 'Design creation is in progress';
      case OrderStatus.laserCutting:
        return 'Material is being laser cut';
      case OrderStatus.autoBending:
        return 'Automatic bending is underway';
      case OrderStatus.manualBending:
        return 'Manual finishing is in progress';

      case OrderStatus.delivered:
        return 'Order delivered successfully';
    }
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isCompleted;

  const _StatusIcon({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? Colors.blue : Colors.grey.shade300,
      ),
      child: Icon(
        isCompleted ? Icons.check : Icons.circle,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}
