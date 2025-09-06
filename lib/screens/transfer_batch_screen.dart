import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/api_client.dart';

class TransferBatchScreen extends StatefulWidget {
  const TransferBatchScreen({super.key});

  @override
  State<TransferBatchScreen> createState() => _TransferBatchScreenState();
}

enum TransferStep {
  scanning,
  confirming,
  transferring,
}

class _TransferBatchScreenState extends State<TransferBatchScreen> {
  final ApiClient _apiClient = ApiClient();
  TransferStep _currentStep = TransferStep.scanning;

  String? _scannedBatchId;
  Map<String, dynamic>? _batchDetails;
  String? _transferToOrgMspId;
  final _newLocationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _onDetect(BarcodeCapture capture) {
    final String? code = capture.barcodes.first.rawValue;
    if (code != null && _currentStep == TransferStep.scanning) {
      _fetchBatchDetails(code);
    }
  }

  Future<void> _fetchBatchDetails(String batchId) async {
    setState(() {
      _currentStep = TransferStep.transferring; // Show loading indicator
      _scannedBatchId = batchId;
    });
    try {
      final batchDetails = await _apiClient.getBatch(batchId);
      setState(() {
        _batchDetails = batchDetails;
        _currentStep = TransferStep.confirming;
      });
    } catch (e) {
      _showErrorAndReset('Error fetching batch details: $e');
    }
  }

  Future<void> _transferBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _currentStep = TransferStep.transferring;
    });

    try {
      final response = await _apiClient.transferBatch(
        _scannedBatchId!,
        _transferToOrgMspId!,
        _newLocationController.text,
      );
      _showSuccessAndNavigate('Batch transferred successfully to ${response['newOwner']['mspId']}');

    } catch (e) {
      _showErrorAndReset('Error transferring batch: $e');
    }
  }

  void _showErrorAndReset(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    setState(() {
      _currentStep = TransferStep.scanning;
      _scannedBatchId = null;
      _batchDetails = null;
    });
  }

  void _showSuccessAndNavigate(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
    context.go('/${_currentUser?.displayName?.toLowerCase() ?? ''}_home');
  }

  void _resetScan() {
    setState(() {
      _currentStep = TransferStep.scanning;
      _scannedBatchId = null;
      _batchDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getAppBarTitle())),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStepUi(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case TransferStep.scanning:
        return 'Scan Batch QR Code';
      case TransferStep.confirming:
        return 'Confirm Transfer';
      case TransferStep.transferring:
        return 'Processing Transfer...';
    }
  }

  Widget _buildCurrentStepUi() {
    switch (_currentStep) {
      case TransferStep.scanning:
        return _buildScanner();
      case TransferStep.confirming:
        return _buildConfirmationForm();
      case TransferStep.transferring:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildScanner() {
    return Column(
      key: const ValueKey('scanner'),
      children: <Widget>[
        Expanded(
          flex: 5,
          child: MobileScanner(
            onDetect: _onDetect,
            controller: MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates),
          ),
        ),
        const Expanded(
          flex: 1,
          child: Center(child: Text('Align QR code within the frame to scan')),
        ),
      ],
    );
  }

  Widget _buildConfirmationForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildBatchDetailsCard(),
          const SizedBox(height: 24),
          TextFormField(
            controller: _newLocationController,
            decoration: const InputDecoration(labelText: 'New Location', hintText: 'e.g., Central Distribution Hub', border: OutlineInputBorder()),
            validator: (value) => (value?.isEmpty ?? true) ? 'Please enter the new location' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _transferToOrgMspId,
            hint: const Text('Transfer To (Organization)'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (String? newValue) {
              setState(() {
                _transferToOrgMspId = newValue;
              });
            },
            items: <String>['DistributorOrgMSP', 'RetailerOrgMSP'] // In a real app, this would be dynamic
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            validator: (value) => value == null ? 'Please select an organization' : null,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Confirm & Transfer'),
            onPressed: _transferBatch,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel and Rescan'),
            onPressed: _resetScan,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Batch Details', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Text('Batch ID: ${_batchDetails!['batchId']}'),
            const SizedBox(height: 8),
            Text('Crop: ${_batchDetails!['cropName']}'),
            const SizedBox(height: 8),
            Text('Current Owner: ${_batchDetails!['owner']['mspId']}'),
          ],
        ),
      ),
    );
  }
}
