import 'package:flutter/material.dart';

class LectureAttendancePage extends StatefulWidget {
  const LectureAttendancePage({super.key});

  @override
  State<LectureAttendancePage> createState() => _LectureAttendancePageState();
}

class _LectureAttendancePageState extends State<LectureAttendancePage> {
  // Example hardcoded student list
  final List<Map<String, dynamic>> students = [
    {'id': 101, 'name': 'katie', 'present': false},
    {'id': 102, 'name': 'mpilohle', 'present': false},
    {'id': 103, 'name': 'patience', 'present': false},
    {'id': 104, 'name': 'ofentse', 'present': false},
  ];

  // Lecture attendance status
  bool lecturePresent = false;

  void _markStudentAttendance(int index, bool? value) {
    setState(() {
      students[index]['present'] = value ?? false;
    });
  }

  void _markLectureAttendance(bool? value) {
    setState(() {
      lecturePresent = value ?? false;
    });
  }

  void _saveAttendance() {
    final presentCount = students.where((s) => s['present']).length;
    final absentCount = students.length - presentCount;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Attendance Saved'),
        content: Text(
          'Lecture Present: ${lecturePresent ? "Yes" : "No"}\n'
              'Students Present: $presentCount\n'
              'Students Absent: $absentCount\n\n'
              'You can connect this to a database!',
        ),
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
        title: const Text('Lecture Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: const Text('Lecture Attendance'),
                subtitle: const Text('Mark if you are present today'),
                trailing: Checkbox(
                  value: lecturePresent,
                  onChanged: _markLectureAttendance,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Student Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                        onChanged: (value) => _markStudentAttendance(index, value),
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
              label: const Text('Save All Attendance'),
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