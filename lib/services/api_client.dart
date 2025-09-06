import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  final String _baseUrl = "http://10.0.2.2:8080"; // Assuming local development server
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> _getIdToken() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  Future<Map<String, dynamic>> createBatch(Map<String, dynamic> batchData) async {
    final String? idToken = await _getIdToken();

    if (idToken == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/batches'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(batchData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to create batch: ${errorBody['error']}');
    }
  }

  Future<Map<String, dynamic>> getBatch(String batchId) async {
    final String? idToken = await _getIdToken();
    if (idToken == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/batches/$batchId'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to get batch details: ${errorBody['error']}');
    }
  }

  Future<Map<String, dynamic>> transferBatch(String batchId, String toOrgMspId, String newLocation, {bool isSeeding = false}) async {
    final String? idToken = await _getIdToken();
    if (idToken == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final Map<String, dynamic> transferData = {
      'toOrgMspId': toOrgMspId,
      'newLocation': newLocation,
      'clientTimestampIso': DateTime.now().toUtc().toIso8601String(),
    };

    if (isSeeding) {
        transferData['seed_mode_bypass_auth'] = true;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/batches/$batchId/transfer'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(transferData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to transfer batch: ${errorBody['error']}');
    }
  }

  Future<List<dynamic>> getBatchHistory(String batchId) async {
    final String? idToken = await _getIdToken();
    // No token needed for public history view

    final response = await http.get(
      Uri.parse('$_baseUrl/api/batches/$batchId/history'),
      headers: {
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to get batch history: ${errorBody['error']}');
      } catch(_) {
         throw Exception('Failed to get batch history: ${response.statusCode}');
      }
    }
  }

  Future<void> seedDemoData() async {
    String? batchId;
    try {
      // 1. Farmer (current user) creates a new batch
      final createBatchResponse = await createBatch({
        'cropName': 'Organic Strawberries',
        'farmName': 'Evergreen Farms',
        'plantingDate': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'harvestDate': DateTime.now().toIso8601String(),
        'location': {'latitude': 34.0522, 'longitude': -118.2437,},
        'clientTimestampIso': DateTime.now().toUtc().toIso8601String(),
      });

      batchId = createBatchResponse['batchId'];
      if (batchId == null) {
        throw Exception('Batch ID was null after creation.');
      }

      await Future.delayed(const Duration(seconds: 1));

      // 2. Transfer to Distributor (using seed mode)
      await transferBatch(batchId, 'DistributorOrgMSP', 'Central Warehouse', isSeeding: true);

      await Future.delayed(const Duration(seconds: 1));

      // 3. Transfer to Retailer (using seed mode)
      await transferBatch(batchId, 'RetailerOrgMSP', 'FreshMart Downtown', isSeeding: true);

    } catch (e) {
      print('Error during data seeding: $e');
      if (batchId == null) {
        throw Exception('Failed to create the initial batch. Check backend logs.');
      } else {
        throw Exception('Failed during transfer for batch $batchId. Check backend logs.');
      }
    }
  }
}
