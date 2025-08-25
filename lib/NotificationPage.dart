import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Spring Fest: Music, Food & Fun This Friday!',
        'message': 'Dear Student,\nGet ready to unwind and celebrate the season—',
        'time': '14:10'
      },
      {
        'title': 'Wellness Workshop: Stress Management Tips',
        'message': 'Dear Student,\nFeeling overwhelmed? Join us for a Wellness Workshop.',
        'time': '12:25'
      },
      {
        'title': 'Free Health Check-up on Campus',
        'message': 'Dear Student,\nDon’t miss your chance to get a free health screening!',
        'time': '10:00'
      },
      {
        'title': 'Hackathon 2025 Registration Open',
        'message': 'Dear Student,\nUnleash your coding skills and creativity—',
        'time': '09:30'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFD9D6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D6F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "NOTIFICATIONS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF3F51B5),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['message']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      item['time']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}