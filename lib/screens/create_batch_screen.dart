import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

import '../services/api_client.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _farmNameController = TextEditingController();

  DateTime? _plantingDate;
  DateTime? _harvestDate;
  bool _isLoading = false;

  final ApiClient _apiClient = ApiClient();
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Handle case where user does not enable location service
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Handle case where user denies location permission
        return;
      }
    }

    try {
      final locationData = await location.getLocation();
      setState(() {
        _locationData = locationData;
      });
    } catch (e) {
      // Handle location fetch errors
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isPlantingDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isPlantingDate) {
          _plantingDate = picked;
        } else {
          _harvestDate = picked;
        }
      });
    }
  }

  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_plantingDate == null || _harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both planting and harvest dates')),
      );
      return;
    }

    if (_locationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch location. Please ensure location services are enabled and permissions granted.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> batchData = {
        'cropName': _cropNameController.text,
        'farmName': _farmNameController.text,
        'plantingDate': _plantingDate!.toIso8601String(),
        'harvestDate': _harvestDate!.toIso8601String(),
        'location': {
          'latitude': _locationData!.latitude,
          'longitude': _locationData!.longitude,
        },
        'clientTimestampIso': DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _apiClient.createBatch(batchData);
      final String batchId = response['batchId'];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully created batch $batchId'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/qr_display/$batchId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating batch: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Batch'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  _buildSectionTitle(context, 'Crop Information'),
                  TextFormField(
                    controller: _cropNameController,
                    decoration: const InputDecoration(labelText: 'Crop Name', hintText: 'e.g., Organic Tomatoes', border: OutlineInputBorder()),
                    validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a crop name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _farmNameController,
                    decoration: const InputDecoration(labelText: 'Farm Name', hintText: 'e.g., Sunrise Farms', border: OutlineInputBorder()),
                    validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a farm name' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Cultivation Timeline'),
                  _buildDateSelector(context, 'Planting Date', _plantingDate, () => _selectDate(context, isPlantingDate: true)),
                  const SizedBox(height: 16),
                  _buildDateSelector(context, 'Harvest Date', _harvestDate, () => _selectDate(context, isPlantingDate: false)),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Origin Location'),
                  _buildLocationInfo(),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Create Batch & Get QR Code'),
                    onPressed: _createBatch,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[800])),
    );
  }

  Widget _buildDateSelector(BuildContext context, String label, DateTime? date, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(date != null ? DateFormat.yMMMd().format(date) : 'Not selected'),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            const Icon(Icons.location_on, color: Colors.blue, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Current Farm Location', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _locationData != null
                        ? 'Lat: ${_locationData!.latitude?.toStringAsFixed(4)}, Lon: ${_locationData!.longitude?.toStringAsFixed(4)}'
                        : 'Fetching location...',
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
