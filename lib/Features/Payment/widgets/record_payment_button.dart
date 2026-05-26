import 'package:flutter/material.dart';

class RecordPaymentButton extends StatelessWidget {

  final VoidCallback onTap;

  const RecordPaymentButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 16,
        ),

        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              Icons.add,
              color: Colors.white,
            ),

            SizedBox(width: 8),

            Text(
              'Record Payment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}