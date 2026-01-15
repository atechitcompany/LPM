import 'package:flutter/material.dart';

class ProductRatingWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRated;

  const ProductRatingWidget({
    super.key,
    required this.rating,
    required this.onRated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate your experience',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Rate the Product',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => onRated(index + 1),
            );
          }),
        ),
      ],
    );
  }
}
