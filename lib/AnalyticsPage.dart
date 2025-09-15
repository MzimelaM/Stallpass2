import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceData = Provider.of<AppState>(context).attendanceData;
    final int totalStudents = attendanceData.length;
    final int presentCount =
        attendanceData.where((student) => student['status'] == 'Present').length;
    final int absentCount =
        attendanceData.where((student) => student['status'] == 'Absent').length;
    final double attendanceRate =
    totalStudents > 0 ? (presentCount / totalStudents * 100) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.people, color: Colors.deepPurple),
                title: const Text('Total Students'),
                trailing: Text(
                  '$totalStudents',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Present'),
                trailing: Text(
                  '$presentCount',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Absent'),
                trailing: Text(
                  '$absentCount',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.deepPurple),
                title: const Text('Attendance Rate'),
                trailing: Text(
                  '${attendanceRate.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final student = attendanceData[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: student['status'] == 'Present'
                          ? Colors.green
                          : Colors.red,
                      child: Text(student['name'][0]),
                    ),
                    title: Text(student['name']),
                    subtitle: Text('ID: ${student['id']}'),
                    trailing: Text(
                      student['status'],
                      style: TextStyle(
                        color: student['status'] == 'Present'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),

            ),
          ],
        ),
      ),
    );
  }
}