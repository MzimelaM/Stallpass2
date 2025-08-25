import 'package:flutter/material.dart';
import 'DepartmentAnnoucementsPage.dart';
import 'NotificationPage.dart';
import 'SuccessPage.dart';
import 'AttendancePage.dart';
import 'ProfileSettingsPage.dart';
import 'ScanQrCode.dart';
import 'events_screen.dart';
import 'state/app_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final int userId; // ✅ constructor parameter
  const HomePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StallPass Event App'),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF3F51B5),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Department Announcements'),
              onTap: () => _navigateTo(context, const DepartmentAnnouncementsPage()),
            ),
            ListTile(
              title: const Text('Notifications'),
              onTap: () => _navigateTo(context, const NotificationPage()),
            ),
            ListTile(
              title: const Text('Campus Events'),
              onTap: () => _navigateTo(
                context,
                EventsScreen(appState: appState),
              ),
            ),
            ListTile(
              title: const Text('Success Page'),
              onTap: () => _navigateTo(context, const SuccessPage()),
            ),
            ListTile(
              title: const Text('Attendance Profile'),
              onTap: () => _navigateTo(context, const AttendancePage()),
            ),
            ListTile(
              title: const Text('Profile Settings'),
              onTap: () {
                // ✅ Pass userId from constructor
                _navigateTo(
                  context,
                  ProfileSettingsPage(userId: userId),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Color(0xFF3F51B5)),
              title: const Text('Scan QR Code'),
              onTap: () => _navigateTo(context, const QRScannerPage()),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to StallPass!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Logged in as user ID: $userId',
              style: const TextStyle(fontSize: 16),
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
