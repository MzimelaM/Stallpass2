import 'package:flutter/material.dart';
import 'StallManagement.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import'AnalyticsPage.dart';

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({super.key});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDateTime;

  List events = [];
  List upcomingEvents = []; // filtered upcoming events
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  // Format DateTime to MySQL DATETIME string
  String formatDateTimeForMySQL(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00";
  }

  /// Fetch all events from backend
  Future<void> fetchEvents() async {
    setState(() => loading = true);
    try {
      var url = Uri.parse('http://10.0.2.2:3000/get_events');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List fetchedEvents = json.decode(response.body);

        // Sort by date & time
        fetchedEvents.sort((a, b) =>
            DateTime.parse(a["event_date"]).compareTo(DateTime.parse(b["event_date"])));

        setState(() {
          events = fetchedEvents;
        });
      }
    } catch (e) {
      print("Error fetching events: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching events: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  /// Create new event
  Future<void> createEvent() async {
    String name = _nameController.text.trim();

    if (name.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter event name and date & time")),
      );
      return;
    }

    String eventDate = formatDateTimeForMySQL(_selectedDateTime!);

    try {
      var url = Uri.parse("http://localhost:3000/create_event");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "event_name": name,
          "event_date": eventDate,
        }),
      );

      if (response.statusCode == 201) {
        var data = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Event Created: ${data["event"]["event_code"]}")),
        );

        _nameController.clear();
        _selectedDateTime = null;

        await fetchEvents();
        // Navigate to StallManagementPage after event creation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StallManagementPage(event: data["event"]),
          ),
        );
      } else {
        var error = json.decode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${error['message']}")));
      }
    } catch (e) {
      print("Error creating event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating event: $e")),
      );
    }
  }

  /// Pick date and time
  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// Get upcoming events
  List getUpcomingEvents() {
    DateTime now = DateTime.now();
    List upcoming = events.where((e) => DateTime.parse(e["event_date"]).isAfter(now)).toList();
    upcoming.sort((a, b) =>
        DateTime.parse(a["event_date"]).compareTo(DateTime.parse(b["event_date"])));
    return upcoming;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Events")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Event name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Event Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Date & Time picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? "No Date & Time Selected"
                        : "Date & Time: ${_selectedDateTime!.toLocal().toString().split('.')[0]}",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDateTime,
                ),
              ],
            ),
            const SizedBox(height: 10),
// View Analytics button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Optional: differentiate the button
              ),
              child: const Text("View Analytics"),
            ),
            const SizedBox(height: 10),

            // Create event
            ElevatedButton(
              onPressed: createEvent,
              child: const Text("Create Event & Generate QR"),
            ),
            const SizedBox(height: 10),

            // View upcoming events
            ElevatedButton(
              onPressed: () {
                setState(() {
                  upcomingEvents = events
                      .where((e) => DateTime.parse(e["event_date"]).isAfter(DateTime.now()))
                      .toList()
                    ..sort((a, b) => DateTime.parse(a["event_date"])
                        .compareTo(DateTime.parse(b["event_date"])));
                });
              },
              child: const Text("View Upcoming Events"),
            ),
            const SizedBox(height: 20),

            // Event list
            loading
                ? const CircularProgressIndicator()
                : Expanded(
              child: events.isEmpty
                  ? const Center(child: Text("No events found"))
                  : ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  var event = events[index];
                  String code = event["event_code"];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event["event_name"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Date & Time: ${event["event_date"].replaceAll('T', ' ')}",
                          ),
                          const SizedBox(height: 4),
                          Text("Code: $code"),
                          const SizedBox(height: 8),
                          Center(
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: QrImageView(
                                data: code,
                                version: QrVersions.auto,
                              ),
                            ),
                          ),
                        ],
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