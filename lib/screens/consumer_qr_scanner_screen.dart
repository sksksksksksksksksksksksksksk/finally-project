
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ConsumerQrScannerScreen extends StatefulWidget {
  const ConsumerQrScannerScreen({super.key});

  @override
  State<ConsumerQrScannerScreen> createState() => _ConsumerQrScannerScreenState();
}

class _ConsumerQrScannerScreenState extends State<ConsumerQrScannerScreen> {
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && _isScanning) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _isScanning = false;
        });
        context.go('/batch_history/$code');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: _onDetect,
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
      ),
    );
  }
}
