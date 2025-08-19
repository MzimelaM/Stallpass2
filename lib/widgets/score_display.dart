import 'package:flutter/material.dart';
import '../state/app_state.dart';

class ScoreDisplay extends StatelessWidget {
  final AppState appState;
  const ScoreDisplay({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 18),
            const SizedBox(width: 6),
            Text('${appState.score}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }
}
