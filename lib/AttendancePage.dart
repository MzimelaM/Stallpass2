import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendancePage extends StatefulWidget {
  final String studentNumber;
  const AttendancePage({super.key, required this.studentNumber});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      var url = Uri.parse("http://10.0.2.2:3000/attendance/${widget.studentNumber}");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
          loading = false;
        });
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e) {
      print("Error fetching events: $e");
      setState(() => loading = false);
    }
  }

  Future<void> confirmAttendance(String eventCode) async {
    try {
      var url = Uri.parse("http://10.0.2.2:3000/confirm_attendance");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "student_number": widget.studentNumber,
          "event_code": eventCode,
        }),
      );

      var data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Attendance confirmed")),
      );

      // Refresh the events list
      fetchEvents();
    } catch (e) {
      print("Error confirming attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          var event = events[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(event["event_name"]),
              subtitle: Text("Code: ${event["event_code"]} | "
                  "Date: ${event["event_date"].replaceAll('T', ' ')} | "
                  "Status: ${event["status"]}"),
              trailing: ElevatedButton(
                onPressed: event["status"] == "Present"
                    ? null
                    : () => confirmAttendance(event["event_code"]),
                child: const Text("Confirm"),
              ),
            ),
          );
        },
      ),
    );
  }
}
