import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StallManagementPage extends StatefulWidget {
  final dynamic event;

  const StallManagementPage({super.key, required this.event});

  @override
  State<StallManagementPage> createState() => _StallManagementPageState();
}

class _StallManagementPageState extends State<StallManagementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _aimController = TextEditingController();
  final TextEditingController _scopeController = TextEditingController();
  final TextEditingController _lessonController = TextEditingController();
  
  List<dynamic> _stalls = [];
  bool _isLoading = true;
  bool _showCreateForm = false;
  String? _generatedQrCode;
  int _selectedIndex = 1; // StallManagementPage index

  @override
  void initState() {
    super.initState();
    _fetchStalls();
  }

  Future<void> _fetchStalls() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/events/${widget.event['id']}/stalls'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _stalls = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load stalls: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stalls: $e')),
      );
    }
  }

  Future<void> _createStall() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stall title is required')),
      );
      return;
    }

    final url = Uri.parse("http://10.0.2.2:3000/admin/stalls");
    final body = jsonEncode({
      'event_id': widget.event['id'],
      'title': _titleController.text,
      'description': _descriptionController.text,
      'about': _aboutController.text,
      'aim': _aimController.text,
      'scope': _scopeController.text,
      'lesson': _lessonController.text,
      'streams': [],
      'careers': [],
      'resources': [],
      'videos': [],
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        setState(() {
          _generatedQrCode = responseData['qrCode'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Stall created successfully")),
        );
        _clearForm();
        _fetchStalls();
      } else {
        final res = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${res['error'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _aboutController.clear();
    _aimController.clear();
    _scopeController.clear();
    _lessonController.clear();
    setState(() => _showCreateForm = false);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/stats');
    }
    // index 1 is StallManagementPage, so we stay here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stalls - ${widget.event['title']}'),
        actions: [
          IconButton(
            icon: Icon(_showCreateForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showCreateForm = !_showCreateForm),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showCreateForm) _buildCreateForm(),
            if (_generatedQrCode != null) _buildQrCodeDialog(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _stalls.isEmpty
                      ? const Center(
                          child: Text(
                            "No stalls available for this event",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _stalls.length,
                          itemBuilder: (context, index) {
                            final stall = _stalls[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(stall['title']),
                                subtitle: Text(stall['description'] ?? 'No description'),
                                trailing: const Icon(Icons.arrow_forward),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Stall Management"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Event Statistics"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCreateForm() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create New Stall",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Stall Title*",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aboutController,
              decoration: const InputDecoration(
                labelText: "About",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aimController,
              decoration: const InputDecoration(
                labelText: "Aim",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _scopeController,
              decoration: const InputDecoration(
                labelText: "Scope",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lessonController,
              decoration: const InputDecoration(
                labelText: "Lesson",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createStall,
                    child: const Text("Create Stall"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeDialog() {
    return AlertDialog(
      title: const Text("Stall Created Successfully"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("QR Code Generated:"),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _generatedQrCode!,
              style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Share this QR code with attendees to scan for attendance",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _generatedQrCode = null),
          child: const Text("OK"),
        ),
      ],
    );
  }
}