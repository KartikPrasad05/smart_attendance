import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../features/student/student_dashboard.dart';
import '../features/faculty/faculty_dashboard.dart';
import '../features/admin/admin_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: auth.getRole(),
      builder: (context, snapshot) {
        // LOADING UI
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          );
        }

        // ERROR OR NO USER
        if (!snapshot.hasData) {
          return _unknownRoleScreen();
        }

        final role = snapshot.data;

        // ROLE-BASED NAVIGATION
        switch (role) {
          case "student":
            return const StudentDashboard();
          case "faculty":
            return const FacultyDashboard();
          case "admin":
            return const AdminDashboard();
          default:
            return _unknownRoleScreen();
        }
      },
    );
  }

  /// Screen shown if a user has no role or invalid role
  Widget _unknownRoleScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              "Unknown or missing role!",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () => auth.logout(),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
