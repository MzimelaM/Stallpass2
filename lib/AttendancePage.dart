import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.blue,
            child: const Center(
              child: Text(
                "My Attendance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Welcome username
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome Username",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),

          // Attendance Timeline heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Attendance Timeline",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),

          // Attendance records list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildAttendanceRecord("IT Faculty - 27 July 2025", true),
                _buildAttendanceRecord("Science Lab - 25 July 2025", true),
                _buildAttendanceRecord("Math Class - 23 July 2025", false),
                _buildAttendanceRecord("Physics Lecture - 20 July 2025", true),
                _buildAttendanceRecord("Chemistry Lab - 18 July 2025", false),
              ],
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Action for "See Upcoming Events"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "See Upcoming Events",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to home
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRecord(String title, bool attended) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: attended ? Colors.green[50] : Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            attended ? Icons.check : Icons.close,
            color: attended ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        subtitle: Text(
          attended ? "Attended" : "Not Attended",
          style: TextStyle(
            color: attended ? Colors.green : Colors.red,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}