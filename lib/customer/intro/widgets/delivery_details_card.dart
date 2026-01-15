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
          children: const [
            Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Home\n152, xyz apt, abc road, 451286',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text('Abc Rst'),
                Spacer(),
                Text('4586237589'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
