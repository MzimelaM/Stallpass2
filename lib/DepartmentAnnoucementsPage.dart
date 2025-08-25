import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DepartmentAnnouncementsPage extends StatefulWidget {
  const DepartmentAnnouncementsPage({super.key});

  @override
  State<DepartmentAnnouncementsPage> createState() =>
      _DepartmentAnnouncementsPageState();
}

class _DepartmentAnnouncementsPageState
    extends State<DepartmentAnnouncementsPage> {
  List<Map<String, dynamic>> _events = [];
  final String apiUrl = "http://10.0.2.2:3000"; // Localhost for Android Emulator

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  /// ✅ Fetch events from Node.js backend
  Future<void> _fetchEvents() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/events"));
      if (response.statusCode == 200) {
        setState(() {
          _events = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load events. Code: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDEBFF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Department Announcements",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF3F51B5),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: _events.isEmpty
            ? const Center(child: Text("No announcements available"))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF3F51B5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event['message'] ?? "No description available.",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event['date'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          event['time'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
