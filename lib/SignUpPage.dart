import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'LoginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _studentNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse("http://10.0.2.2:3000/signup");
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": _fullNameController.text.trim(),
          "student_number": _studentNumberController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
          "role": "user",   // 👈 tell backend this is a normal user
        }),
      );

      final body = json.decode(response.body);
      final message = body['message'] ?? 'Unknown response';

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginPage()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D6F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Column(
                  children: const [
                    Icon(Icons.qr_code, size: 80, color: Color(0xFF3F51B5)),
                    SizedBox(height: 10),
                    Text("STALL PASS",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5))),
                    Text("SCAN.ENGAGE.SUCCEED",
                        style: TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 40),

                const Text("Create Account",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),


                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                  ),
                  validator: (v) => _validateNotEmpty(v, 'Full Name'),
                ),
                const SizedBox(height: 15),


                TextFormField(
                  controller: _studentNumberController,
                  decoration: InputDecoration(
                    hintText: "Student Number",
                    prefixIcon: const Icon(Icons.badge),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                  ),
                  validator: (v) => _validateNotEmpty(v, 'Student Number'),
                ),
                const SizedBox(height: 15),


                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => _validateNotEmpty(v, 'Email'),
                ),
                const SizedBox(height: 15),


                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                  ),
                  validator: (v) => _validateNotEmpty(v, 'Password'),
                ),
                const SizedBox(height: 20),


                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up", style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Or continue with"),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_mobiledata, size: 40, color: Colors.red),
                    SizedBox(width: 20),
                    Icon(Icons.apple, size: 40, color: Colors.black),
                    SizedBox(width: 20),
                    Icon(Icons.facebook, size: 40, color: Colors.blue),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage())),
                      child: const Text("Sign In",
                          style: TextStyle(
                              color: Color(0xFF3F51B5),
                              fontWeight: FontWeight.bold)),
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
}
