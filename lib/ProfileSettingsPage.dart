import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileSettingsPage extends StatefulWidget {
  final String studentNumber; // Use student number instead of userId

  const ProfileSettingsPage({super.key, required this.studentNumber});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _isLoading = true);

    try {
      final url = "http://10.0.2.2:3000/user/${widget.studentNumber}";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final user = json.decode(response.body);

        setState(() {
          _nameController.text = user['full_name'] ?? '';
          _studentController.text = user['student_number'] ?? '';
          _emailController.text = user['email'] ?? '';
          _passwordController.text = user['password'] ?? '';
          _isLoading = false;
        });
      } else {
        throw Exception(
            "Failed to load user (status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user: $e")),
      );
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.put(
        Uri.parse("http://10.0.2.2:3000/user/${widget.studentNumber}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "full_name": _nameController.text,
          "student_number": _studentController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        setState(() => _isEditing = false);
      } else {
        throw Exception("Update failed (status: ${response.statusCode})");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating user: $e")),
      );
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD9D6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        title: const Text("Profile Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person, size: 80, color: Color(0xFF3F51B5)),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration:
                        _inputDecoration("Full Name", Icons.person),
                        validator: (value) =>
                        value!.isEmpty ? "Name cannot be empty" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _studentController,
                        enabled: false, // student number cannot be edited
                        decoration: _inputDecoration(
                            "Student Number", Icons.badge),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        enabled: _isEditing,
                        decoration: _inputDecoration("Email", Icons.email),
                        validator: (value) =>
                        !value!.contains('@') ? "Enter a valid email" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (_isEditing && value!.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isEditing) {
                      _updateUser();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _isEditing ? "Save" : "Edit",
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

