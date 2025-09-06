
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_client.dart';

class BatchHistoryScreen extends StatefulWidget {
  final String batchId;

  const BatchHistoryScreen({super.key, required this.batchId});

  @override
  State<BatchHistoryScreen> createState() => _BatchHistoryScreenState();
}

class _BatchHistoryScreenState extends State<BatchHistoryScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiClient.getBatchHistory(widget.batchId);
  }

  IconData _getIconForOwner(String mspId) {
    if (mspId.toLowerCase().contains('farmer')) {
      return Icons.eco;
    } else if (mspId.toLowerCase().contains('distributor')) {
      return Icons.local_shipping;
    } else if (mspId.toLowerCase().contains('retailer')) {
      return Icons.store;
    }
    return Icons.person;
  }

  String _getTitleForOwner(String mspId) {
    if (mspId.toLowerCase().contains('farmer')) {
      return "Farmed";
    } else if (mspId.toLowerCase().contains('distributor')) {
      return "Distributed";
    } else if (mspId.toLowerCase().contains('retailer')) {
      return "Retailed";
    }
    return "Owned";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch History: ${widget.batchId}'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history found for this batch.'));
          }

          final history = snapshot.data!;

          return Stepper(
            controlsBuilder: (BuildContext context, ControlsDetails details) {
                return const SizedBox.shrink();
            },
            steps: history.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final value = item['value'];
              final timestamp = DateTime.parse(item['timestamp']);
              final formattedDate = DateFormat.yMMMd().add_jm().format(timestamp);
              final ownerMspId = value['owner']['mspId'];

              return Step(
                title: Text(
                  _getTitleForOwner(ownerMspId),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Owner: $ownerMspId'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: ${value['location']}'),
                    const SizedBox(height: 4),
                    Text(formattedDate),
                  ],
                ),
                isActive: true,
                state: StepState.complete,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
