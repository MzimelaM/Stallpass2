import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'ConfirmAttendance.dart'; // New page for pre-confirm

class NotificationPage extends StatefulWidget {
  final String studentNumber; // Add this
  const NotificationPage({super.key, required this.studentNumber});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:3000/get_events"));
      if (response.statusCode == 200) {
        setState(() {
          notifications = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, i) {
            final event = notifications[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(event['event_name']),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd').format(DateTime.parse(event['event_date'])),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to ConfirmAttendance page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmAttendance(
                        studentNumber: widget.studentNumber,
                        event: event,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
