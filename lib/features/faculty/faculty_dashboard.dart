import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_firestore_service.dart';
import 'create_session_screen.dart';
import 'session_management_screen.dart';
import 'attendance_analytics_screen.dart';
import 'session_report_screen.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  final SessionFirestoreService _service = SessionFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Dashboard"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // 🔥 OVERVIEW PANEL
            Expanded(
              child: StreamBuilder<Map<String, int>>(
                stream: _service.getProfessorOverview(),
                builder: (context, snap) {
                  final data = snap.data ?? {
                    'totalSessions': 0,
                    'activeSessions': 0,
                    'totalPresent': 0,
                    'totalStudents': 0,
                  };

                  return Column(
                    children: [
                      _infoTile("Total Sessions", data['totalSessions'].toString(), Icons.event),
                      _infoTile("Active Sessions", data['activeSessions'].toString(), Icons.play_circle_fill),
                      _infoTile("Total Students Marked Present", data['totalPresent'].toString(), Icons.check_circle),
                      _infoTile("Unique Students", data['totalStudents'].toString(), Icons.people),
                      const SizedBox(height: 20),

                      // 🔥 ACTION BUTTONS
                      _actionTile(
                        icon: Icons.qr_code_2,
                        label: "Create Session",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSessionScreen())),
                      ),
                      _actionTile(
                        icon: Icons.manage_history,
                        label: "Manage Sessions",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionManagementScreen())),
                      ),
                      _actionTile(
                        icon: Icons.analytics,
                        label: "Attendance Analytics",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceAnalyticsScreen())),
                      ),
                      _actionTile(
                        icon: Icons.download,
                        label: "Generate Reports",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionReportScreen())),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _actionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}
