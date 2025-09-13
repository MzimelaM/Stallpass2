import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'StallScreen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class StallManagementPage extends StatefulWidget {
  final dynamic event;

  const StallManagementPage({super.key, required this.event});

  @override
  State<StallManagementPage> createState() => _StallManagementPageState();
}

class _StallManagementPageState extends State<StallManagementPage> {
  // State variables
  int? _editingStallId;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _aimController = TextEditingController();
  final TextEditingController _scopeController = TextEditingController();
  final TextEditingController _lessonController = TextEditingController();
  List<dynamic> _stalls = [];
  bool _isLoading = true;
  bool _showCreateForm = false;
  bool _isCreating = false;
  int _selectedIndex = 1;

  // Helper methods
  // Helper: build text field with validation
  Widget _buildTextField(TextEditingController controller, String label, bool required, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[<>]')),
      ],
      textInputAction: TextInputAction.next,
    );
  }


  Future<void> _createStall() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);
    final url = Uri.parse('http://localhost:3000/events/${widget.event['event_id'] ?? widget.event['id']}/stalls');
    final body = jsonEncode({
      'title': _sanitize(_titleController.text),
      'description': _sanitize(_descriptionController.text),
      'about': _sanitize(_aboutController.text),
      'aim': _sanitize(_aimController.text),
      'scope': _sanitize(_scopeController.text),
      'lesson': _sanitize(_lessonController.text),
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        await fetchStalls();
        _clearForm();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Stall Created'),
            content: const Text('Do you want to add another stall to this event?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _showCreateForm = true;
                  });
                  // Do NOT fetch stalls here
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    _showCreateForm = false;
                  });
                  await fetchStalls();
                },
                child: const Text('No'),
              ),
            ],
          ),
        );
      } else {
        final res = jsonDecode(response.body);
        _showError("❌ Failed: ${res['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      _showError("❌ Error: $e");
    } finally {
      setState(() => _isCreating = false);
    }
  }

  Future<void> updateStall(int stallId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCreating = true);
    final url = Uri.parse("http://localhost:3000/lecturer/stalls/$stallId");
    final body = jsonEncode({
      'title': _sanitize(_titleController.text),
      'description': _sanitize(_descriptionController.text),
      'about': _sanitize(_aboutController.text),
      'aim': _sanitize(_aimController.text),
      'scope': _sanitize(_scopeController.text),
      'lesson': _sanitize(_lessonController.text),
    });
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (response.statusCode == 200) {
        _showSuccessDialog();
        _clearForm();
        await fetchStalls();
      } else {
        final res = jsonDecode(response.body);
        _showError("❌ Failed: ${res['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      _showError("❌ Error: $e");
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _showCreateForm = true;
    _isLoading = false;
    // Do not fetch stalls on initial load
  }


  Future<void> fetchStalls() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/events/${widget.event['event_id'] ?? widget.event['id']}/stalls'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _stalls = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load stalls: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error fetching stalls: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // Removed stray code outside of methods. All logic is now inside methods.


  String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>]'), '');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stall Created'),
        content: const Text('Your stall was created successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        title: Text('Stalls - ${widget.event['title'] ?? widget.event['event_name']}'),
        actions: [
          IconButton(
            icon: Icon(_showCreateForm ? Icons.close : Icons.add),
            tooltip: _showCreateForm ? 'Close form' : 'Add stall',
            onPressed: () {
              setState(() {
                _showCreateForm = !_showCreateForm;
                _editingStallId = null;
                _clearForm();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showCreateForm)
              _buildCreateForm(),
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit Stall',
                                      onPressed: () {
                                        setState(() {
                                          _showCreateForm = true;
                                          _editingStallId = stall['stall_id'];
                                          _titleController.text = stall['title'] ?? '';
                                          _descriptionController.text = stall['description'] ?? '';
                                          _aboutController.text = stall['about'] ?? '';
                                          _aimController.text = stall['aim'] ?? '';
                                          _scopeController.text = stall['scope'] ?? '';
                                          _lessonController.text = stall['lesson'] ?? '';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            if (_isCreating)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _editingStallId == null ? "Create New Stall" : "Edit Stall",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(_titleController, "Stall Title*", true, maxLines: 1),
                const SizedBox(height: 12),
                _buildTextField(_descriptionController, "Description", false, maxLines: 2),
                const SizedBox(height: 12),
                _buildTextField(_aboutController, "About", false, maxLines: 3),
                const SizedBox(height: 12),
                _buildTextField(_aimController, "Aim", false, maxLines: 2),
                const SizedBox(height: 12),
                _buildTextField(_scopeController, "Scope", false, maxLines: 2),
                const SizedBox(height: 12),
                _buildTextField(_lessonController, "Lesson", false, maxLines: 2),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreating
                            ? null
                            : () {
                                if (_editingStallId == null) {
                                  _createStall();
                                } else {
                                  updateStall(_editingStallId!);
                                }
                              },
                        child: Text(_editingStallId == null ? "Create Stall" : "Update Stall"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isCreating ? null : _clearForm,
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // QR code dialog removed
}