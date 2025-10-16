import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ new import

import 'AttendancePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRScannerPage extends StatefulWidget {
  final String studentNumber;
  const QRScannerPage({super.key, required this.studentNumber});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request(); // ✅ use permission_handler
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission is required to scan QR codes.")),
      );
    }
  }


  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return; // prevent multiple triggers

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    String scannedCode = barcodes.first.rawValue ?? "";
    if (scannedCode.isEmpty) return;

    print("QR detected: $scannedCode"); // DEBUG
    setState(() => _isProcessing = true);

    await _confirmAttendance(scannedCode.trim());

    // Reset processing so scanner can detect another QR after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  Future<void> _confirmAttendance(String eventCode) async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/attendance/confirm");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "student_number": widget.studentNumber,
          "event_code": eventCode,
        }),
      );

      if (response.statusCode != 200) {
        try {
          final error = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ ${error["message"] ?? "Failed to confirm"}")),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Server error: ${response.statusCode}")),
          );
        }
        return;
      }

      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "✅ Attendance confirmed")),
      );

      // Navigate back to AttendancePage
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AttendancePage(studentNumber: widget.studentNumber),
        ),
      );
    } catch (e) {
      print("Error confirming attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error confirming attendance: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
