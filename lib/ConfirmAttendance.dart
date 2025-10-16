import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ConfirmAttendance extends StatefulWidget {
  final String studentNumber;
  final Map<String, dynamic> event;

  const ConfirmAttendance({super.key, required this.studentNumber, required this.event});

  @override
  State<ConfirmAttendance> createState() => _ConfirmAttendanceState();
}

class _ConfirmAttendanceState extends State<ConfirmAttendance> {
  bool _isLoading = false;

  // ✅ For "I will attend"
  Future<void> _preConfirmAttendance() async {
    await _sendAttendanceStatus("Will attend");
  }

  // ✅ For "I will not attend"
  Future<void> _willNotAttend() async {
    await _sendAttendanceStatus("Will not attend");
  }

  // ✅ Shared method for both actions
  Future<void> _sendAttendanceStatus(String status) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/attendance/update_status"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "student_number": widget.studentNumber,
          "event_code": widget.event['event_code'],
          "status": status,
        }),
      );

      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Status updated')),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(event['event_name']),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event['event_name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "📅 ${DateFormat('yyyy-MM-dd').format(DateTime.parse(event['event_date']))}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                if (event['event_description'] != null)
                  Text(
                    event['event_description'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      // ✅ "I will attend" button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _preConfirmAttendance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "I will attend",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ❌ "I will not attend" button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _willNotAttend,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "I will not attend",
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
