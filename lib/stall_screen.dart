import 'package:flutter/material.dart';
import '../models.dart';
import '../state/app_state.dart';
import 'stall_detail_screen.dart';

class StallScreen extends StatelessWidget {
  final Event event;
  final AppState appState;

  const StallScreen({super.key, required this.event, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: event.stalls.length,
        itemBuilder: (context, index) {
          final stall = event.stalls[index];
          final completed = appState.isStallCompleted(stall.id);
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(stall.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(stall.description),
                  const SizedBox(height: 8),
                  Row(children: [
                    Chip(
                      label: Text(stall.activityType),
                      backgroundColor: Colors.blue.shade50,
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                    const SizedBox(width: 8),
                    if (completed) const Chip(label: Text('Completed ✅')),
                  ]),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StallDetailScreen(stall: stall, appState: appState),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
