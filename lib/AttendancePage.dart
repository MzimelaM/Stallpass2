import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> _attendance = [];

  // Change to your backend IP if testing on real device
  final String apiUrl = "http://10.0.2.2:3000";

  // For now we hardcode studentId = "S1001"
  final String studentId = "S1001";

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    final response =
    await http.get(Uri.parse("$apiUrl/attendance/$studentId"));
    if (response.statusCode == 200) {
      setState(() {
        _attendance =
        List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D6F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ATTENDANCE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF3F51B5),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _attendance.isEmpty
          ? const Center(child: Text("No attendance records"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _attendance.length,
        itemBuilder: (context, index) {
          final record = _attendance[index];
          final bool present = record['status'] == "Present";

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                present ? Icons.check_circle : Icons.cancel,
                color: present ? Colors.green : Colors.red,
                size: 32,
              ),
              title: Text(
                record['title'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                "${record['date']} at ${record['time'] ?? ''}",
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: present
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  present ? "Present" : "Absent",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: present ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}