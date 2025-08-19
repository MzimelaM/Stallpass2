// lib/screens/stall_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models.dart';
import '../state/app_state.dart';
import 'quiz_screen.dart';
import 'coding_challenge_screen.dart';
import 'mini_game_screen.dart';
import 'poll_screen.dart';

class StallDetailScreen extends StatelessWidget {
  final Stall stall;
  final AppState appState;

  const StallDetailScreen({
    super.key,
    required this.stall,
    required this.appState,
  });

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    bool isCompleted = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = appState.isStallCompleted(stall.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(stall.title),
        actions: [
          if (isCompleted)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle, color: Colors.green),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information sections
            if (stall.description.isNotEmpty) ...[
              _sectionHeader('Description'),
              Text(stall.description),
            ],

            if (stall.about.isNotEmpty) ...[
              _sectionHeader('About'),
              Text(stall.about),
            ],

            if (stall.aim.isNotEmpty) ...[
              _sectionHeader('Aim'),
              Text(stall.aim),
            ],

            if (stall.scope.isNotEmpty) ...[
              _sectionHeader('Scope'),
              Text(stall.scope),
            ],

            if (stall.lesson.isNotEmpty) ...[
              _sectionHeader('Key Lessons'),
              Text(stall.lesson),
            ],

            if (stall.streams.isNotEmpty) ...[
              _sectionHeader('Streams'),
              ...stall.streams.map(
                (stream) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• ${stream.name}: ${stream.description}'),
                ),
              ),
            ],

            if (stall.careers.isNotEmpty) ...[
              _sectionHeader('Career Opportunities'),
              ...stall.careers.map(
                (career) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $career'),
                ),
              ),
            ],

            if (stall.resources.isNotEmpty) ...[
              _sectionHeader('Resources'),
              ...stall.resources.map(
                (resource) => InkWell(
                  onTap: () => _launchUrl(resource.url),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${resource.title}',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            if (stall.videos.isNotEmpty) ...[
              _sectionHeader('Video Resources'),
              ...stall.videos.map(
                (video) => InkWell(
                  onTap: () => _launchUrl(video.url),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '▶ ${video.title}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Activities section
            _sectionHeader('Activities'),
            if (stall.quizQuestions.isNotEmpty)
              _buildActivityTile(
                icon: Icons.quiz,
                color: Colors.purple,
                title: 'Take Quiz (${stall.quizQuestions.length} questions)',
                isCompleted: isCompleted,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      stall: stall,
                      appState: appState,
                    ),
                  ),
                ),
              ),

            if (stall.coding != null)
              _buildActivityTile(
                icon: Icons.code,
                color: Colors.green,
                title: 'Coding Challenge',
                isCompleted: isCompleted,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CodingChallengeScreen(
                      stall: stall,
                      appState: appState,
                    ),
                  ),
                ),
              ),

            if (stall.miniGameEnabled)
              _buildActivityTile(
                icon: Icons.videogame_asset,
                color: Colors.orange,
                title: 'Play Mini Game',
                isCompleted: isCompleted,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MiniGameScreen(
                      stall: stall,
                      appState: appState,
                    ),
                  ),
                ),
              ),

            if (stall.pollQuestion.isNotEmpty)
              _buildActivityTile(
                icon: Icons.poll,
                color: Colors.blue,
                title: 'Participate in Poll',
                isCompleted: isCompleted,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PollScreen(
                      stall: stall,
                      appState: appState,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
