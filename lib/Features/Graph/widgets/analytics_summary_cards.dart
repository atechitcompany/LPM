import 'package:flutter/material.dart';

class AnalyticsSummaryCards extends StatelessWidget {
  final int totalJobs;
  final int completedJobs;
  final int pendingJobs;
  final int deliveredJobs;

  const AnalyticsSummaryCards({
    super.key,
    required this.totalJobs,
    required this.completedJobs,
    required this.pendingJobs,
    required this.deliveredJobs,
  });

  Widget buildCard(String title, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        buildCard(
          'Total Jobs',
          totalJobs.toString(),
          Colors.blue,
        ),
        buildCard(
          'Completed',
          completedJobs.toString(),
          Colors.green,
        ),
        buildCard(
          'Pending',
          pendingJobs.toString(),
          Colors.orange,
        ),
        buildCard(
          'Delivered',
          deliveredJobs.toString(),
          Colors.purple,
        ),
      ],
    );
  }
}