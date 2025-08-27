import 'package:flutter/material.dart';
import '../models.dart';
import '../state/app_state.dart';

class QuizScreen extends StatefulWidget {
  final Stall stall;
  final AppState appState;
  const QuizScreen({super.key, required this.stall, required this.appState});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int correct = 0;
  int? selected;

  @override
  Widget build(BuildContext context) {
    final q = widget.stall.quizQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.stall.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
                value: (currentIndex + 1) / widget.stall.quizQuestions.length),
            const SizedBox(height: 16),
            Text(
                'Question ${currentIndex + 1} of ${widget.stall.quizQuestions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(q.question, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ...q.options.asMap().entries.map((e) => RadioListTile<int>(
                  value: e.key,
                  groupValue: selected,
                  onChanged: (v) => setState(() => selected = v),
                  title: Text(e.value),
                )),
            const Spacer(),
            Row(
              children: [
                TextButton(
                    onPressed: currentIndex == 0 ? null : _prev,
                    child: const Text('Back')),
                const Spacer(),
                ElevatedButton(
                  onPressed: selected == null ? null : _nextOrFinish,
                  child: Text(
                      currentIndex == widget.stall.quizQuestions.length - 1
                          ? 'Finish'
                          : 'Next'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _prev() {
    setState(() {
      selected = null;
      currentIndex -= 1;
    });
  }

  void _nextOrFinish() {
    final q = widget.stall.quizQuestions[currentIndex];
    if (selected == q.correctAnswer) correct += 1;

    if (currentIndex == widget.stall.quizQuestions.length - 1) {
      final gained = correct * 10;
      widget.appState.addScore(gained);
      widget.appState.markStallCompleted(widget.stall);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Quiz Complete'),
          content: Text(
              'Score: $correct / ${widget.stall.quizQuestions.length}\nYou earned +$gained points!\nStreak: ${widget.appState.streak} 🔥'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        ),
      ).then((_) => Navigator.pop(context));
    } else {
      setState(() {
        currentIndex += 1;
        selected = null;
      });
    }
  }
}
