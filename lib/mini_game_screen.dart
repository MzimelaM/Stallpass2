import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models.dart';
import '../state/app_state.dart';

class MiniGameScreen extends StatefulWidget {
  final Stall stall;
  final AppState appState;
  const MiniGameScreen(
      {super.key, required this.stall, required this.appState});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  static const int gridSize = 9;
  static const int gameSeconds = 20;
  final Random _rng = Random();
  int targetIndex = 0;
  int score = 0;
  int timeLeft = gameSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    targetIndex = _rng.nextInt(gridSize);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();
        _finish();
      } else {
        setState(() {
          timeLeft -= 1;
          targetIndex = _rng.nextInt(gridSize);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stall.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $timeLeft s'),
                Text('Hits: $score'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: gridSize,
                itemBuilder: (context, index) {
                  final isTarget = index == targetIndex;
                  return GestureDetector(
                    onTap: () {
                      if (isTarget) setState(() => score += 1);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isTarget
                            ? Colors.greenAccent
                            : Colors.blueGrey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isTarget
                                ? Colors.green
                                : Colors.blueGrey.shade300,
                            width: 2),
                      ),
                      child: Center(child: Text(isTarget ? 'Tap!' : '')),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finish() {
    final gained = score >= 10 ? 15 : 8;
    widget.appState.addScore(gained);
    widget.appState.markStallCompleted(widget.stall);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(
            'You scored $score hits.\nYou earned +$gained points!\nStreak: ${widget.appState.streak} 🔥'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    ).then((_) => Navigator.pop(context));
  }
}
