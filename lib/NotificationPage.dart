import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  bool _loading = true;
  final String apiUrl = "http://10.0.2.2:3000"; // change for real device

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final resp = await http.get(Uri.parse("$apiUrl/get_events"));
      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);

        setState(() {
          notifications = data.map<Map<String, dynamic>>((e) {
            final m = e as Map<String, dynamic>;
            final dt = DateTime.parse(m["event_date"]);
            return {
              "title": m["event_name"],
              "code": m["event_code"], // keep raw code for QR
              "date": DateFormat('yyyy-MM-dd').format(dt),
              "time": DateFormat('hh:mm a').format(dt),
            };
          }).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load: ${resp.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching notifications: $e")),
      );
    }
  }

  // put this INSIDE the State class so onTap can call it
  void _showNotificationDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item['title'] ?? 'Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Event Code: ${item['code'] ?? ''}"),
            const SizedBox(height: 12),
            QrImageView(
              data: item['code'] ?? '',
              version: QrVersions.auto,
              size: 150,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _showNotificationDetails(context, item),
      child: Container(
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
                item['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Event Code: ${item['code'] ?? ''}",
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item['date'] != null)
                    Text(item['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (item['time'] != null)
                    Text(item['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: QrImageView(
                  data: item['code'] ?? '',
                  version: QrVersions.auto,
                  size: 120,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D6F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "NOTIFICATIONS",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3F51B5)),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text("No notifications yet"))
          : RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, i) => _buildNotificationCard(notifications[i]),
        ),
      ),
    );
  }
}
