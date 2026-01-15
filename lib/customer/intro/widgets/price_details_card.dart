import 'package:flutter/material.dart';

class PriceDetailsCard extends StatelessWidget {
  const PriceDetailsCard({super.key});

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('Listing Price', '₹650'),
            _row('Selling Price', '₹500'),
            _row('Discount', '-₹20'),
            _row('Total fees', '₹5'),
            const Divider(),
            _row('Total', '₹485', bold: true),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Payment Method'),
                Chip(label: Text('Cash on Delivery')),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download Invoice'),
                onPressed: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
