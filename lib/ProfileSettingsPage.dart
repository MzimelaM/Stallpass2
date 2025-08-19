import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileSettingsPage extends StatefulWidget {
  final int userId;

  const ProfileSettingsPage({super.key, required this.userId});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
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
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/user/${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        setState(() {
          _nameController.text = user['fullName'];
          _emailController.text = user['email'];
          _passwordController.text = user['password'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.put(
        Uri.parse("http://10.0.2.2:3000/user/${widget.userId}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "fullName": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
        setState(() => _isEditing = false);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.person, size: 80, color: Color(0xFF3F51B5)),
                const SizedBox(height: 10),
                const Text(
                  "Your Profile",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5)),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  decoration: _inputDecoration("Full Name", Icons.person),
                  validator: (value) =>
                  value!.isEmpty ? "Name cannot be empty" : null,
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
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (_isEditing && value!.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      _isEditing ? const Color(0xFF3F51B5) : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isEditing ? _updateUser : null,
                    child: _isEditing
                        ? const Text("Save Changes", style: TextStyle(fontSize: 18))
                        : const Text("Edit Profile", style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 15),
                if (!_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        setState(() => _isEditing = true);
                      },
                      child: const Text("Edit Profile", style: TextStyle(fontSize: 18)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

