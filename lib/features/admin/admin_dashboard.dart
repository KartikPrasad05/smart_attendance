// lib/features/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../../services/admin_firestore_service.dart';
import 'manage_users_screen.dart';
import 'attendance_reports_screen.dart';
import 'sessions_admin_screen.dart';
import 'subjects_admin_screen.dart';
import 'admin_analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminFirestoreService _service = AdminFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Analytics summary (small)
            FutureBuilder<Map<String, int>>(
              future: _service.basicAnalytics(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
                final d = snap.data!;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _smallCard('Students', d['students'] ?? 0),
                    _smallCard('Faculty', d['faculty'] ?? 0),
                    _smallCard('Sessions', d['sessions'] ?? 0),
                    _smallCard('Attendance', d['attendance'] ?? 0),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),

            // Action tiles
            Expanded(
              child: ListView(
                children: [
                  _actionTile(Icons.people, 'Manage Users', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen()))),
                  const SizedBox(height: 12),
                  _actionTile(Icons.bar_chart, 'Attendance Reports', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReportsScreen()))),
                  const SizedBox(height: 12),
                  _actionTile(Icons.schedule, 'Sessions', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionsAdminScreen()))),
                  const SizedBox(height: 12),
                  _actionTile(Icons.book, 'Subjects', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectsAdminScreen()))),
                  const SizedBox(height: 12),
                  _actionTile(Icons.analytics, 'Analytics (detailed)', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _smallCard(String label, int value) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String text, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
