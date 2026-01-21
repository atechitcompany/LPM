import 'package:flutter/material.dart';

class PriceDetailsCard extends StatelessWidget {
  const PriceDetailsCard({super.key});

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Heading
        const Text(
          'Price Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        /// Grey price box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _row('Listing Price', '₹650'),
              _row('Selling Price', '₹500'),
              _row('Discount', '-₹20'),
              _row('Total fees', '₹5'),

              const Divider(height: 24),

              _row('Total', '₹485', bold: true),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 13),
                  ),
                  Chip(
                    label: Text('Cash on Delivery'),
                  ),
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
      ],
    );
  }
}
