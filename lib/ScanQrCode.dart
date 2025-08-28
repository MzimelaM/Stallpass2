import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      String scannedCode = barcodes.first.rawValue ?? "";
      if (scannedCode.isNotEmpty) {
        setState(() => _isProcessing = true);
        await _confirmAttendance(scannedCode);
      }
    }
  }

  Future<void> _confirmAttendance(String eventCode) async {
    try {
      var url = Uri.parse("http://10.0.2.2:3000/confirm_attendance");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "student_number": widget.studentNumber,
          "event_code": eventCode,
        }),
      );

      var data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Attendance confirmed")),
      );

      // Navigate to AttendancePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AttendancePage(studentNumber: widget.studentNumber),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error confirming attendance: $e")),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _onDetect,
      ),
    );
  }
}
