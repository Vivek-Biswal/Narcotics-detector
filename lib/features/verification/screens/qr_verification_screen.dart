import 'package:flutter/material.dart';

class QrVerificationScreen extends StatelessWidget {
  final String mode;
  const QrVerificationScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Verification')),
      body: Center(child: Text('QR Verification Mode: $mode')),
    );
  }
}
