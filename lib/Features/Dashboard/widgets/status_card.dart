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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 120,
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$count $status',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Immediate Follow-up',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: 4),
            Text('Tap for details',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}