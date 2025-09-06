import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_client.dart';

class ConsumerBatchHistoryScreen extends StatefulWidget {
  final String batchId;

  const ConsumerBatchHistoryScreen({super.key, required this.batchId});

  @override
  State<ConsumerBatchHistoryScreen> createState() => _ConsumerBatchHistoryScreenState();
}

class _ConsumerBatchHistoryScreenState extends State<ConsumerBatchHistoryScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiClient.getBatchHistory(widget.batchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Journey'),
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
          } else {
            final history = snapshot.data!;
            final firstEvent = history.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(firstEvent),
                  const SizedBox(height: 30),
                  _buildTimeline(history),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> firstEvent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstEvent['value']['cropName'] ?? 'N/A',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Batch ID: ${widget.batchId}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
         Text(
          'Farm: ${firstEvent['value']['farmName'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildTimeline(List<dynamic> history) {
    return Column(
      children: history.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> event = entry.value;
        bool isFirst = index == 0;
        bool isLast = index == history.length - 1;

        return _buildTimelineTile(
          event: event,
          isFirst: isFirst,
          isLast: isLast,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineTile({required Map<String, dynamic> event, required bool isFirst, required bool isLast}) {
    final eventData = event['value'];
    final mspId = eventData['owner']?['mspId']?.replaceAll('OrgMSP', '') ?? 'Unknown';
    final timestamp = DateTime.parse(event['timestamp']);
    final formattedDate = DateFormat.yMMMd().format(timestamp);
    final formattedTime = DateFormat.jm().format(timestamp);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildTimelineConnector(isFirst, isLast),
          const SizedBox(width: 20),
          Expanded(child: _buildTimelineEventCard(mspId, formattedDate, formattedTime, eventData)),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(bool isFirst, bool isLast) {
    return Column(
      children: <Widget>[
        Container(
          width: 2,
          height: 20,
          color: isFirst ? Colors.transparent : Colors.grey,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFirst ? Colors.green : Colors.blue,
          ),
        ),
        Expanded(
          child: Container(
            width: 2,
            color: isLast ? Colors.transparent : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineEventCard(String mspId, String date, String time, Map<String, dynamic> eventData) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              mspId,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('$date at $time'),
              ],
            ),
            const SizedBox(height: 12),
            Text('Location: ${eventData['location']?['display_name'] ?? 'Not available'}'),
          ],
        ),
      ),
    );
  }
}
