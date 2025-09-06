import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/api_client.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isSeeding = false;

  Future<void> _seedData() async {
    setState(() {
      _isSeeding = true;
    });
    try {
      await _apiClient.seedDemoData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data seeded successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Welcome, ${user?.email ?? 'Farmer'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildDashboardCard(
              icon: Icons.add_circle,
              title: 'Create New Batch',
              subtitle: 'Start a new crop batch and generate a QR code.',
              onTap: () => context.go('/create_batch'),
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            _buildDashboardCard(
              icon: Icons.qr_code_scanner,
              title: 'Scan & Transfer Batch',
              subtitle: 'Scan a QR code to transfer ownership of a batch.',
              onTap: () => context.go('/transfer_batch'),
              color: Colors.blue,
            ),
            const Spacer(),
            const Divider(height: 40),
            const Text(
              'For Demo Purposes',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            _isSeeding
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Seed Demo Data'),
                    onPressed: _seedData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
