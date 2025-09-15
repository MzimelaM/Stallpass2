import 'package:flutter/material.dart';
import 'AttendancePage.dart';
import 'NotificationPage.dart';
import 'SuccessPage.dart';
import 'ProfileSettingsPage.dart';
import 'ScanQrCode.dart';

class HomePage extends StatelessWidget { 
  const HomePage({super.key, required String studentNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D6F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
              onTap: () {
                _navigateTo(context, const NotificationPage());
              },
            ),
            ListTile(
              title: const Text('Success Page'),
              onTap: () {
                _navigateTo(context, const SuccessPage());
              },
            ),
            ListTile(
              title: const Text('Attendance Profile'),
              onTap: () {
                _navigateTo(context, const AttendancePage());
              },
            ),
            ListTile(
              title: const Text('Profile Settings'),
              onTap: () {
                _navigateTo(context, const ProfileSettingsPage(studentNumber: '',));
              },
            ),ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Color(0xFF3F51B5)),
              title: const Text('Scan QR Code'),
              onTap: () {
                // Make sure studentNumber is defined in this page (from login or stored session)
                String studentNumber = "2023001"; // Example, replace with actual logged-in student
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QRScannerPage(studentNumber: studentNumber), // camelCase!
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
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}