import 'package:flutter/material.dart';

class SidebarLogo extends StatelessWidget {
  const SidebarLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Center(
          child: Image.asset(
            'assets/LPM.jpg',
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'Light Punch Maker',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(thickness: 0.8),
      ],
    );
  }
}