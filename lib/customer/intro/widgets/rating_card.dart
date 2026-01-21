import 'package:flutter/material.dart';

class RatingCard extends StatefulWidget {
  const RatingCard({super.key});

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate your experience',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Rate the Product',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),

        /// ⭐ CENTERED STARS (NO CARD, NO SHADOW)
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starValue = index + 1;

              return InkWell(
                onTap: () {
                  setState(() {
                    _rating = starValue;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    _rating >= starValue
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 26,
                  ),
                ),
              );
            }),
          ),
        ),

        if (_rating > 0) ...[
          const SizedBox(height: 8),

        ],
      ],
    );
  }
}
