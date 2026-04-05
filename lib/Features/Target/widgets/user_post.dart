import 'package:flutter/material.dart';

class UserPost extends StatelessWidget {
  final String post;

  const UserPost({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Text(
      post,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
