import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  const ProgressBar({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: value),
        const SizedBox(height: 6),
        Text('Completed $completed / $total activities'),
      ],
    );
  }
}
