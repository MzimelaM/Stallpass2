import 'package:flutter/material.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();


  final TextEditingController _nameController =
  TextEditingController(text: "FullName");
  final TextEditingController _studentNumberController =
  TextEditingController(text: "STD2025001");
  final TextEditingController _emailController =
  TextEditingController(text: "john.doe@university.edu");
  final TextEditingController _passwordController = TextEditingController();


  late String _initialName;
  late String _initialStudentNumber;
  late String _initialEmail;

  bool _isEditing = false;
  bool _obscurePassword = true;


  static const Color pagePurple = Color(0xFFD9D9FF);
  static const Color accentBlue = Color(0xFF5A63FF);

  @override
  void initState() {
    super.initState();
    _initialName = _nameController.text;
    _initialStudentNumber = _studentNumberController.text;
    _initialEmail = _emailController.text;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  InputDecoration _fieldDecoration({
    required String label,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      prefixIcon: Icon(prefixIcon, color: accentBlue),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pagePurple,
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back_ios_new, color: Colors.black54),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "PERSONAL INFO",
                    style: TextStyle(
                      color: accentBlue,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),

            // Avatar
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFEDF0FF),
                      child: const Icon(Icons.person, size: 56, color: accentBlue),
                    ),
                  ),

                  Positioned(
                    right: MediaQuery.of(context).size.width / 2 - 90,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        onPressed: () {

                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: pagePurple,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [

                            _buildFieldContainer(
                              child: TextFormField(
                                controller: _nameController,
                                enabled: _isEditing,
                                decoration: _fieldDecoration(
                                  label: "Full Name",
                                  prefixIcon: Icons.person,
                                ),
                                validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Enter your name'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),


                            _buildFieldContainer(
                              child: TextFormField(
                                controller: _studentNumberController,
                                enabled: _isEditing,
                                decoration: _fieldDecoration(
                                  label: "Student Number",
                                  prefixIcon: Icons.badge,
                                ),
                                validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Enter student number'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Email
                            _buildFieldContainer(
                              child: TextFormField(
                                controller: _emailController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _fieldDecoration(
                                  label: "Email",
                                  prefixIcon: Icons.email,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter an email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Password
                            _buildFieldContainer(
                              child: TextFormField(
                                controller: _passwordController,
                                enabled: _isEditing,
                                obscureText: _obscurePassword,
                                decoration: _fieldDecoration(
                                  label: "Password",
                                  prefixIcon: Icons.lock,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: accentBlue,
                                    ),
                                    onPressed: () => setState(
                                            () => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (value) {
                                  if (_isEditing &&
                                      value != null &&
                                      value.isNotEmpty &&
                                      value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 22),


                            if (_isEditing) ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text(
                                    "SAVE CHANGES",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],


                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isEditing ? _cancelEditing : _toggleEditing,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  _isEditing ? Colors.grey : accentBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  _isEditing ? "CANCEL" : "UPDATE PROFILE",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),


                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleLogout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  "LOG OUT",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }


  void _toggleEditing() {
    setState(() {
      _initialName = _nameController.text;
      _initialStudentNumber = _studentNumberController.text;
      _initialEmail = _emailController.text;
      _isEditing = true;
    });
  }


  void _cancelEditing() {
    setState(() {
      _nameController.text = _initialName;
      _studentNumberController.text = _initialStudentNumber;
      _emailController.text = _initialEmail;
      _passwordController.clear();
      _isEditing = false;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {

      setState(() {

        _initialName = _nameController.text;
        _initialStudentNumber = _studentNumberController.text;
        _initialEmail = _emailController.text;
        _passwordController.clear();
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);

            },
            child: const Text("LOG OUT", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
