import 'package:flutter/material.dart';
import '../models.dart';
import '../state/app_state.dart';

class CodingChallengeScreen extends StatefulWidget {
  final Stall stall;
  final AppState appState;
  const CodingChallengeScreen(
      {super.key, required this.stall, required this.appState});

  @override
  State<CodingChallengeScreen> createState() => _CodingChallengeScreenState();
}

class _CodingChallengeScreenState extends State<CodingChallengeScreen> {
  final Map<int, TextEditingController> _controllers = {};
  int passed = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < (widget.stall.coding?.tests.length ?? 0); i++) {
      _controllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.stall.coding!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.stall.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Challenge', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(challenge.prompt),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: challenge.tests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = challenge.tests[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Test ${index + 1}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Input: ${t.input}'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Your output',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Expected pattern: ${t.expectedOutput}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                ElevatedButton(onPressed: _submit, child: const Text('Submit')),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _submit() {
    final tests = widget.stall.coding!.tests;
    passed = 0;

    for (int i = 0; i < tests.length; i++) {
      final user = _controllers[i]!.text.trim();
      final expected = tests[i].expectedOutput.trim();
      if (_normalize(user) == _normalize(expected)) {
        passed += 1;
      }
    }

    final gained =
        passed == tests.length ? 20 : 10;
    widget.appState.addScore(gained);
    widget.appState.markStallCompleted(widget.stall);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Challenge Result'),
        content: Text(
            'Passed $passed / ${tests.length} tests.\nYou earned +$gained points!\nStreak: ${widget.appState.streak} 🔥'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    ).then((_) => Navigator.pop(context));
  }

  String _normalize(String s) => s.replaceAll(RegExp(r'\s+'), '');
}
