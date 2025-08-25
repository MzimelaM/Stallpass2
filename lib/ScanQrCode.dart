import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});



  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}


class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = false;
  String? _scannedData;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Scan Your QR Code",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Scanner block with instructions
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _scannedData == null
                        ? "Align the QR code within the frame to scan"
                        : "Scan successful!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Scanner container
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _scannedData == null ? Colors.blue : Colors.green,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          MobileScanner(
                            controller: cameraController,
                            onDetect: (capture) {
                              final List<Barcode> barcodes = capture.barcodes;
                              if (barcodes.isNotEmpty) {
                                setState(() {
                                  _scannedData = barcodes.first.rawValue;
                                  _isScanning = false;
                                });
                              }
                            },
                          ),
                          if (_scannedData == null)
                            Center(
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Scanned data (hidden until scan is complete)
                  if (_scannedData != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      "Scanned Data:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _scannedData!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Button section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _scannedData != null ? _confirmAttendance : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "CONFIRM ATTENDANCE",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "BACK TO HOME",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleScanner,
        backgroundColor: Colors.blue,
        child: Icon(
          _isScanning ? Icons.stop : Icons.qr_code_scanner,
          color: Colors.white,
        ),
      ),
    );
  }

  void _toggleScanner() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _scannedData = null;
        cameraController.start();
      } else {
        cameraController.stop();
      }
    });
  }

  void _confirmAttendance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Attendance"),
        content: Text("Confirm attendance for:\n\n$_scannedData"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Attendance confirmed successfully!"),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() {
                _scannedData = null;
                _isScanning = false;
                cameraController.stop();
              });
            },
            child: const Text(
              "CONFIRM",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}