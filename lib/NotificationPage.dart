import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'ConfirmAttendance.dart';

class NotificationPage extends StatefulWidget {
  final String studentNumber; // ✅ student number passed from previous page
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

  void _showNotificationDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          event['event_name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "📅 ${DateFormat('yyyy-MM-dd').format(DateTime.parse(event['event_date']))}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (event['event_description'] != null)
              Text(
                event['event_description'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // close popup
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
            child: const Text(
              "Confirm Attendance",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                title: Text(
                  event['event_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "📅 ${DateFormat('yyyy-MM-dd').format(DateTime.parse(event['event_date']))}",
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showNotificationDetails(event),
              ),
            );
          },
        ),
      ),
    );
  }
}
