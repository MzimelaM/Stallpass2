import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class StallScreen extends StatelessWidget {
  final dynamic event;

  const StallScreen({super.key, required this.event});

  Future<List<dynamic>> _fetchStalls() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/events/${event['id']}/stalls'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load stalls: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stalls: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['title'] ?? 'Event Stalls'),
        backgroundColor: const Color(0xFF3F51B5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StallScreen(event: event),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchStalls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading stalls...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load stalls',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StallScreen(event: event),
                        ),
                      );
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Stalls Available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no stalls for ${event['title'] ?? 'this event'} yet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final stalls = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StallScreen(event: event),
                ),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stalls.length,
              itemBuilder: (context, index) {
                final stall = stalls[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getStallColor(stall),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStallIcon(stall),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      stall['title'] ?? 'Untitled Stall',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (stall['description'] != null && stall['description'].toString().isNotEmpty)
                          Text(
                            stall['description'].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        const SizedBox(height: 8),
                        if (_hasStallDetails(stall))
                          const Text(
                            'Tap to view details →',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showStallInfo(context, stall);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper method to determine stall color based on type or content
  Color _getStallColor(dynamic stall) {
    final activityType = stall['activity_type']?.toString().toLowerCase() ?? '';
    
    if (activityType.contains('workshop')) return Colors.orange.shade700;
    if (activityType.contains('demo')) return Colors.green.shade700;
    if (activityType.contains('lecture')) return Colors.purple.shade700;
    if (activityType.contains('exhibition')) return Colors.red.shade700;
    
    return Colors.blue.shade700;
  }

  // Helper method to determine stall icon based on type or content
  IconData _getStallIcon(dynamic stall) {
    final activityType = stall['activity_type']?.toString().toLowerCase() ?? '';
    
    if (activityType.contains('workshop')) return Icons.build;
    if (activityType.contains('demo')) return Icons.science;
    if (activityType.contains('lecture')) return Icons.school;
    if (activityType.contains('exhibition')) return Icons.art_track;
    
    return Icons.storefront;
  }

  // Helper method to check if stall has additional details
  bool _hasStallDetails(dynamic stall) {
    return (stall['about'] != null && stall['about'].toString().isNotEmpty) ||
           (stall['aim'] != null && stall['aim'].toString().isNotEmpty) ||
           (stall['scope'] != null && stall['scope'].toString().isNotEmpty) ||
           (stall['lesson'] != null && stall['lesson'].toString().isNotEmpty);
  }

  void _showStallInfo(BuildContext context, dynamic stall) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stall['title'] ?? 'Stall Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (stall['description'] != null && stall['description'].toString().isNotEmpty) ...[
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(stall['description'].toString()),
                const SizedBox(height: 16),
              ],
              
              if (stall['about'] != null && stall['about'].toString().isNotEmpty) ...[
                const Text(
                  'About:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(stall['about'].toString()),
                const SizedBox(height: 16),
              ],
              
              if (stall['aim'] != null && stall['aim'].toString().isNotEmpty) ...[
                const Text(
                  'Aim:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(stall['aim'].toString()),
                const SizedBox(height: 16),
              ],
              
              if (stall['scope'] != null && stall['scope'].toString().isNotEmpty) ...[
                const Text(
                  'Scope:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(stall['scope'].toString()),
                const SizedBox(height: 16),
              ],
              
              if (stall['lesson'] != null && stall['lesson'].toString().isNotEmpty) ...[
                const Text(
                  'Lesson:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(stall['lesson'].toString()),
                const SizedBox(height: 16),
              ],
              
              if (stall['activity_type'] != null && stall['activity_type'].toString().isNotEmpty) ...[
                const Text(
                  'Activity Type:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(stall['activity_type'].toString()),
                  backgroundColor: Colors.blue.shade50,
                ),
              ],

              // Add QR code information if available
              if (stall['qr_code'] != null && stall['qr_code'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'QR Code:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    stall['qr_code'].toString(),
                    style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scan this code at the stall to mark attendance',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}