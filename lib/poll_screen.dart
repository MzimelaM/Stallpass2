import 'package:flutter/material.dart';
import '../models.dart';
import '../state/app_state.dart';

class PollScreen extends StatefulWidget {
  final Stall stall;
  final AppState appState;

  const PollScreen({
    super.key,
    required this.stall,
    required this.appState,
  });

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stall.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.stall.pollQuestion,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...widget.stall.pollOptions.map(
              (option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedOption,
                onChanged: (value) => setState(() => selectedOption = value),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedOption == null
                    ? null
                    : () {
                        widget.appState.addScore(5);
                        widget.appState.markStallCompleted(widget.stall);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Thanks for voting: $selectedOption'),
                          ),
                        );
                      },
                child: const Text('Submit Vote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
