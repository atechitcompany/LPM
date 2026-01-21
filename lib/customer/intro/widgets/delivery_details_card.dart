import 'package:flutter/material.dart';

class DeliveryDetailsCard extends StatelessWidget {
  const DeliveryDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Delivery Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Home    152, xyz apt, abc road, 451286',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 18),
                SizedBox(width: 8),
                Text('Abc Rst    4586237589'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
