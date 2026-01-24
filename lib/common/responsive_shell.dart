import 'package:flutter/material.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;

  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // 📱 Mobile
        if (width < 600) {
          return child;
        }

        // 📱 Tablet
        if (width < 1024) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: child,
            ),
          );
        }

        // 🖥️ Web / Desktop → USE FULL SCREEN
        return child;
      },
    );
  }
}
