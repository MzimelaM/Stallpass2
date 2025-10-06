import 'package:flutter/material.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AdminLoginPage(),
    );
  }
}

/// -----------------------------
/// LOGIN PAGE
/// -----------------------------
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController staffIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6D6F5),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Column(
                children: const [
                  Icon(Icons.qr_code, size: 80, color: Colors.teal),
                  SizedBox(height: 10),
                  Text("STALL PASS",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text("SCAN.ENGAGE.SUCCEED",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Welcome Back!",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 20),

              // Staff ID
              TextField(
                controller: staffIdController,
                decoration: InputDecoration(
                  hintText: "Staff ID",
                  prefixIcon: const Icon(Icons.badge),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // Password
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ),

              // Sign In button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminHomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text("Sign In",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// -----------------------------
/// ADMIN HOME PAGE WITH 3 BUTTONS
/// -----------------------------
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AnalyticsPage()));
              },
              child: const Text('Analytics'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EventManagementPage()));
              },
              child: const Text('Event Management'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Page3()));
              },
              child: const Text('Another Admin Page'),
            ),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------
/// ANALYTICS PAGE (Student Attendance Only)
/// -----------------------------
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool showAnalytics = true;
  final List<String> studentsPresent = [];
  final List<String> previousStudents = [];

  void toggleAnalytics() {
    setState(() => showAnalytics = !showAnalytics);
  }

  void resetAttendance() {
    setState(() {
      studentsPresent.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalStudents = studentsPresent.length;
    final double studentPercent =
    totalStudents > 0 ? (totalStudents / totalStudents) * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Student Attendance Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: toggleAnalytics,
                  child:
                  Text(showAnalytics ? 'Hide Analytics' : 'Show Analytics'),
                ),
                ElevatedButton(
                  onPressed: resetAttendance,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reset Attendance'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (showAnalytics) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Students Present',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: studentsPresent.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                        leading: const Icon(Icons.person_outline,
                            color: Colors.green),
                        title: Text(studentsPresent[index]),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Attendance Stats',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                'Students: ${studentPercent.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// -----------------------------
/// EVENT MANAGEMENT PAGE
/// -----------------------------
class EventManagementPage extends StatelessWidget {
  const EventManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Event Management')),
        body: const Center(child: Text('Manage your events here')));
  }
}

/// -----------------------------
/// PAGE 3
/// -----------------------------
class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Page 3')),
        body: const Center(child: Text('This is another Admin page')));
  }
}
