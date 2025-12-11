import 'package:flutter/material.dart';

class EmbossPage extends StatefulWidget {
  const EmbossPage({super.key});

  @override
  State<EmbossPage> createState() => _EmbossPageState();
}

class _EmbossPageState extends State<EmbossPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Center(
        child: Container(
          child: Text("Emboss"),
        ),
      ),
    );
  }
}
