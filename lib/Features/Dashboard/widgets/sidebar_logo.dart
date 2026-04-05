import 'package:flutter/material.dart';

class SidebarLogo extends StatelessWidget {
  const SidebarLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        Image.asset(
          'assets/sidebar_logo.jpeg', // ✅ Make sure this path matches your asset
          height: 25,
        ),
        SizedBox(height: 8),

        Center(
          child: Text(
            'A Tech IT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Divider(thickness: 1),
      ],
    );
  }
}