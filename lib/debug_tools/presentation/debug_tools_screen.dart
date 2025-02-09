import 'package:flutter/material.dart';

/// Screen for debug tools, only available in debug mode
class DebugToolsScreen extends StatelessWidget {
  const DebugToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Debug Tools Screen'),
    );
  }
}
