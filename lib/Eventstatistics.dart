import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventStatisticsPage extends StatefulWidget {
  const EventStatisticsPage({super.key});

  @override
  State<EventStatisticsPage> createState() => _EventStatisticsPageState();
}

class _EventStatisticsPageState extends State<EventStatisticsPage> {
  List<Map<String, dynamic>> _stats = [];
  final String apiUrl = "http://10.0.2.2:3000";

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final response = await http.get(Uri.parse("$apiUrl/event-stats"));
    if (response.statusCode == 200) {
      setState(() {
        _stats = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Statistics"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _stats.isEmpty
          ? const Center(child: Text("No statistics available"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stats.length,
        itemBuilder: (context, index) {
          final stat = _stats[index];
          return Card(
            child: ListTile(
              title: Text(stat['title']),
              subtitle:
              Text("Attendance: ${stat['present']} / ${stat['total']}"),
            ),
          );
        },
      ),
    );
  }
}