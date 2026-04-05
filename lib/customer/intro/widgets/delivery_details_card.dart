import 'package:flutter/material.dart';

class DeliveryDetailsCard extends StatelessWidget {
  const DeliveryDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Heading
        const Text(
          'Delivery Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 8),

        /// Grey details box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: const [
              /// Address row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '152, xyz apt, abc road, 451286',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              /// Contact row
              Row(
                children: [
                  Icon(Icons.person, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Abc Rst',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '4586237589',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
