import 'package:flutter/material.dart';
import '../../../models/test_record.dart';

class TestDetailsScreen extends StatelessWidget {
  final TestRecord? record;
  const TestDetailsScreen({super.key, this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Details')),
      body: Center(child: Text('Test Details Placeholder: ${record?.testId ?? "None"}')),
    );
  }
}
