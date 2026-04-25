import 'package:flutter/material.dart';

Widget sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  ),
);

Widget fieldCard({required Widget child}) => Container(
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
      ),
    ],
  ),
  child: child,
);