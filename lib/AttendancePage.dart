import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ScanQrCode.dart';

class AttendancePage extends StatefulWidget {
  final String studentNumber;
  const AttendancePage({super.key, required this.studentNumber});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List events = [];
  List filteredEvents = [];
  bool loading = true;
  bool searching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      var url = Uri.parse(
          "http://10.0.2.2:3000/attendance/${widget.studentNumber}");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
          filteredEvents = events;
          loading = false;
        });
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e) {
      print("Error fetching events: $e");
      setState(() => loading = false);
    }
  }

  void filterEvents(String query) {
    final results = events.where((event) {
      final name = event["event_name"].toString().toLowerCase();
      final code = event["event_code"].toString().toLowerCase();
      return name.contains(query.toLowerCase()) ||
          code.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredEvents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searching
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
          onChanged: filterEvents,
        )
            : const Text("Attendance"),
        actions: [
          IconButton(
            icon: Icon(searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (searching) {
                  searchController.clear();
                  filteredEvents = events;
                }
                searching = !searching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      QRScannerPage(studentNumber: widget.studentNumber),
                ),
              );
              if (result == true) {
                fetchEvents(); // refresh list after scanning
              }
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : filteredEvents.isEmpty
          ? const Center(child: Text("No attendance records found"))
          : ListView.builder(
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          var event = filteredEvents[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(event["event_name"]),
              subtitle: Text(
                  "Code: ${event["event_code"]} | Date: ${event["event_date"].replaceAll('T', ' ')}"),
              trailing: Chip(
                label: Text(
                  event["status"],
                  style: TextStyle(
                    color: event["status"] == "Present"
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
