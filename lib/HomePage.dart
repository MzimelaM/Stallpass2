import 'package:flutter/material.dart';
import 'AttendancePage.dart';
import 'NotificationPage.dart';
import 'SuccessPage.dart';
import 'ProfileSettingsPage.dart';
import 'ScanQrCode.dart';

class HomePage extends StatelessWidget {
  final String studentNumber; // Passed from login
  const HomePage({super.key, required this.studentNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D6F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // hamburger menu color
        automaticallyImplyLeading: true, // ensures menu icon is shown
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black), // optional title
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFD9D6F5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFD9D6F5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Color(0xFF3F51B5),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Notifications'),
              onTap: () => _navigateTo(context, NotificationPage(studentNumber: studentNumber)),

            ),
            ListTile(
              title: const Text('Success Page'),
              onTap: () => _navigateTo(context, const SuccessPage()),
            ),
            ListTile(
              title: const Text('Attendance Profile'),
              onTap: () => _navigateTo(
                context,
                AttendancePage(studentNumber: studentNumber),
              ),
            ),
            ListTile(
              title: const Text('Profile Settings'),
              onTap: () => _navigateTo(context, ProfileSettingsPage(studentNumber: studentNumber)),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Color(0xFF3F51B5)),
              title: const Text('Scan QR Code'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QRScannerPage(studentNumber: studentNumber),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code, size: 100, color: Color(0xFF3F51B5)),
            SizedBox(height: 20),
            Text(
              'WELCOME TO STALLPASS!!!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Manage your Event Participation easily.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
