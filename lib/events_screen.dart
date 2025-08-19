import 'package:flutter/material.dart';
import '../models.dart';
import '../state/app_state.dart';
import 'stall_screen.dart';
import '../widgets/score_display.dart';
import '../widgets/streak_badge.dart';

class EventsScreen extends StatelessWidget {
  final AppState appState;
  EventsScreen({super.key, required this.appState});

  final List<Event> events = [
    Event(
      id: 'event1',
      title: 'Bellville Open Day',
      date: '15 September 2025',
      location: 'Bellville Campus',
      description: 'Explore our campus facilities and academic programs',
      stalls: [
        Stall(
          id: 'stallICT',
          title: 'Diploma in ICT',
          description: 'Overview of the Diploma, streams, and careers',
          activityType: 'Info + Activities',
          about:
              'The Diploma in ICT equips students with skills in programming, networking, and multimedia for diverse IT careers.',
          aim:
              'Provide practical, industry-relevant IT knowledge and prepare graduates for specialization in high-demand IT fields.',
          scope:
              'Three streams: Application Development, Communications Development, Multimedia. Includes theory and hands-on practice.',
          lesson:
              'Understand how software, networks, and multimedia integrate to deliver modern digital solutions.',
          streams: const [
            StreamInfo(
                name: 'Application Development',
                description:
                    'Programming (e.g., Java/Dart), databases, APIs, system design.'),
            StreamInfo(
                name: 'Communications Development',
                description:
                    'Networking, cloud, cybersecurity, and infrastructure.'),
            StreamInfo(
                name: 'Multimedia',
                description:
                    'Graphics, animation, user experience, interactive media.'),
          ],
          careers: const [
            'Software Engineer',
            'Mobile Developer',
            'Systems Analyst',
            'Network Engineer',
            'Cybersecurity Analyst',
            'IT Support Engineer',
            'Multimedia Designer',
            'Game Developer',
            'UX/UI Designer',
          ],
          resources: const [
            ResourceLink(
                title: 'Application Development Basics',
                url: 'https://www.youtube.com/watch?v=rfscVS0vtbw'),
            ResourceLink(
                title: 'Networking Fundamentals',
                url: 'https://www.youtube.com/watch?v=qiQR5rTSshw'),
          ],
          videos: const [
            ResourceLink(
                title: 'Intro to Multimedia Design',
                url: 'https://www.youtube.com/watch?v=Q0K5Eo7JQwQ'),
          ],
          quizQuestions: [
            QuizQuestion(
              question: 'Which stream focuses on programming and databases?',
              options: [
                'Application Dev',
                'Communications',
                'Multimedia',
                'All of them'
              ],
              correctAnswer: 0,
            ),
            QuizQuestion(
              question: 'Which role aligns with Communications Development?',
              options: [
                'UX Designer',
                'Network Engineer',
                'Animator',
                '3D Artist'
              ],
              correctAnswer: 1,
            ),
          ],
          coding: CodingChallenge(
            prompt:
                'Given two integers a and b, output a+b. Provide outputs for the test inputs below.',
            tests: [
              TestCase(input: 'a=10, b=5', expectedOutput: '15'),
              TestCase(input: 'a=-2, b=7', expectedOutput: '5'),
            ],
          ),
          miniGameEnabled: true,
        ),
        Stall(
          id: 'stall1',
          title: 'Campus Tour',
          description: 'Guided tour of our facilities',
          activityType: 'Quiz',
          quizQuestions: [
            QuizQuestion(
              question: 'Which building houses the Engineering department?',
              options: ['A Block', 'B Block', 'C Block', 'D Block'],
              correctAnswer: 2,
            ),
          ],
        ),
        Stall(
          id: 'stall2',
          title: 'Program Info',
          description: 'Learn about our academic offerings',
          activityType: 'Poll',
          pollQuestion: 'Which program interests you most?',
          pollOptions: ['Engineering', 'Business', 'Health Sciences', 'Arts'],
        ),
      ],
    ),
    Event(
      id: 'event2',
      title: 'AWS Event',
      date: '20 August 2025',
      location: 'District 6 Campus, Engineering Building',
      description: 'Cloud computing workshop and career opportunities',
      stalls: [
        Stall(
          id: 'stall4',
          title: 'Cloud Workshop',
          description: 'Hands-on AWS cloud lab',
          activityType: 'Quiz',
          quizQuestions: [
            QuizQuestion(
              question: 'What does AWS stand for?',
              options: [
                'Amazon Web Services',
                'Advanced Web Systems',
                'Automated Workflow Service',
                'Application Web Server'
              ],
              correctAnswer: 0,
            ),
          ],
        ),
        Stall(
          id: 'stall5',
          title: 'Career Paths',
          description: 'Explore tech career opportunities',
          activityType: 'Poll',
          pollQuestion: 'Which AWS career path interests you?',
          pollOptions: [
            'Solutions Architect',
            'Developer',
            'SysOps Admin',
            'Data Engineer'
          ],
        ),
        Stall(
          id: 'stall6',
          title: 'Certification',
          description: 'Learn about AWS certifications',
          activityType: 'Coding Challenge',
          coding: CodingChallenge(
            prompt:
                'Write a program that, given two integers a and b, returns their sum.',
            tests: [
              TestCase(input: 'a=2, b=3', expectedOutput: '5'),
              TestCase(input: 'a=-4, b=10', expectedOutput: '6'),
              TestCase(input: 'a=0, b=0', expectedOutput: '0'),
            ],
          ),
        ),
      ],
    ),
    Event(
      id: 'event3',
      title: 'Tech Conference',
      date: '10 September 2025',
      location: 'District 6 Campus, Engineering Building',
      description: 'Annual technology conference with industry leaders',
      stalls: [
        Stall(
          id: 'stall7',
          title: 'AI Workshop',
          description: 'Introduction to Machine Learning',
          activityType: 'Quiz',
          quizQuestions: [
            QuizQuestion(
              question: 'What does ML stand for in AI?',
              options: [
                'Multiple Learning',
                'Machine Learning',
                'Main Logic',
                'Meta Language'
              ],
              correctAnswer: 1,
            ),
          ],
        ),
        Stall(
          id: 'stall8',
          title: 'Coding Challenge',
          description: 'Test your programming skills',
          activityType: 'Coding Challenge',
          coding: CodingChallenge(
            prompt: 'Given a string s, return the string reversed.',
            tests: [
              TestCase(input: 's="abc"', expectedOutput: 'cba'),
              TestCase(input: 's="racecar"', expectedOutput: 'racecar'),
            ],
          ),
        ),
        Stall(
          id: 'stall9',
          title: 'Tech Trends',
          description: 'Vote on emerging technologies',
          activityType: 'Poll',
          pollQuestion: 'Which tech trend excites you most?',
          pollOptions: ['AI', 'Blockchain', 'Quantum Computing', 'IoT'],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: ScoreDisplay(appState: appState)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StreakBadge(appState: appState)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final totalActivities = event.stalls.length;
          final completed =
              event.stalls.where((s) => appState.isStallCompleted(s.id)).length;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StallScreen(event: event, appState: appState),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(event.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Chip(label: Text(event.date)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(event.description),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.location)),
                    ]),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                        value: totalActivities == 0
                            ? 0
                            : completed / totalActivities),
                    const SizedBox(height: 6),
                    Text('Completed $completed / $totalActivities activities'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => appState.resetProgress(),
        label: const Text('Reset Progress'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}
