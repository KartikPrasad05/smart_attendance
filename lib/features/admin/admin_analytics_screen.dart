// lib/features/admin/admin_analytics_screen.dart
import 'package:flutter/material.dart';
import '../../services/admin_firestore_service.dart';
class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});
  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final AdminFirestoreService _service = AdminFirestoreService();
  Map<String,int>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await _service.basicAnalytics();
    setState(() => _data = d);
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return Scaffold(appBar: AppBar(title: const Text('Analytics'), backgroundColor: Colors.deepPurple), body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(child: ListTile(title: const Text('Total Students'), trailing: Text('${_data!['students']}'))),
            Card(child: ListTile(title: const Text('Total Faculty'), trailing: Text('${_data!['faculty']}'))),
            Card(child: ListTile(title: const Text('Total Sessions'), trailing: Text('${_data!['sessions']}'))),
            Card(child: ListTile(title: const Text('Total Attendance Records'), trailing: Text('${_data!['attendance']}'))),
            const SizedBox(height: 12),
            const Text('Custom charts can be added — suggest which visualizations you want.'),
          ],
        ),
      ),
    );
  }
}
