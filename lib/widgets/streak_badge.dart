import 'package:flutter/material.dart';
import '../state/app_state.dart';

class StreakBadge extends StatelessWidget {
  final AppState appState;
  const StreakBadge({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final s = appState.streak;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$s', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Text('🔥', style: TextStyle(fontSize: 18)),
          ],
        );
      },
    );
  }
}
