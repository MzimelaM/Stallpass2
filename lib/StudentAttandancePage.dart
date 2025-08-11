import 'package:flutter/material.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  // Example hardcoded student list
  final List<Map<String, dynamic>> students = [
    {'id': 101, 'name': 'John Doe', 'present': false},
    {'id': 102, 'name': 'Jane Smith', 'present': false},
    {'id': 103, 'name': 'Michael Brown', 'present': false},
    {'id': 104, 'name': 'Emily Johnson', 'present': false},
  ];

  void _markAttendance(int index, bool? value) {
    setState(() {
      students[index]['present'] = value ?? false;
    });
  }

  void _saveAttendance() {
    // Here, you could send to backend or save locally
    // For now, just show a dialog with summary
    final presentCount = students.where((s) => s['present']).length;
    final absentCount = students.length - presentCount;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Attendance Saved'),
        content: Text(
            'Present: $presentCount\nAbsent: $absentCount\n\nYou can connect this to a database!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(student['name'][0]),
                      ),
                      title: Text(student['name']),
                      subtitle: Text('ID: ${student['id']}'),
                      trailing: Checkbox(
                        value: student['present'],
                        onChanged: (value) => _markAttendance(index, value),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveAttendance,
              icon: const Icon(Icons.save),
              label: const Text('Save Attendance'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}