import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'LoginPage.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String studentNumber;

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
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
          _confirmPasswordController.text = user['password'] ?? '';
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load user (status: ${response.statusCode})");
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
      labelText: hint,
      prefixIcon: Icon(icon, size: 20), // smaller icons
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), // smaller padding
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25), // slightly smaller radius
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
        title: const Text("Profile Settings", style: TextStyle(fontSize: 18)), // smaller title
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      const Icon(Icons.person, size: 60, color: Color(0xFF3F51B5)), // smaller icon
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration: _inputDecoration("Full Name", Icons.person),
                        style: const TextStyle(fontSize: 14),
                        validator: (value) =>
                        value!.isEmpty ? "Name cannot be empty" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _studentController,
                        enabled: false,
                        decoration: _inputDecoration("Student Number", Icons.badge),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        enabled: _isEditing,
                        decoration: _inputDecoration("Email", Icons.email),
                        style: const TextStyle(fontSize: 14),
                        validator: (value) =>
                        !value!.contains('@') ? "Enter a valid email" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: _isEditing,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (_isEditing && value!.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        enabled: _isEditing,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          prefixIcon: const Icon(Icons.lock, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                            ),
                            onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (value) {
                          if (_isEditing && value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Buttons at bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 45, // smaller button height
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEditing) {
                          _updateUser();
                        } else {
                          setState(() {
                            _isEditing = true;
                            _confirmPasswordController.text =
                                _passwordController.text;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text(
                        _isEditing ? "Save" : "Edit",
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.black, size: 20),
                      label: const Text("Logout", style: TextStyle(fontSize: 16, color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



