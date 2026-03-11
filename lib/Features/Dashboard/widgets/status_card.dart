import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String status;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const StatusCard({
    Key? key,
    required this.status,
    required this.count,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  String get _subtitle {
    switch (status) {
      case 'Hot':
        return 'Immediate Follow-up';
      case 'Paid':
        return 'Immediate Follow-up';
      case 'Cold':
        return 'Immediate Follow-up';
      case 'Done':
        return 'Completed Jobs';
      default:
        return 'Immediate Follow-up';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 110,
        margin: const EdgeInsets.only(right: 10, top: 10, bottom: 4),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: "3 Hot"
            Text(
              '$count $status',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            // Middle: "Immediate Follow-up"
            Text(
              _subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            // Bottom: "Tap for Details"
            const Text(
              'Tap for Details',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}