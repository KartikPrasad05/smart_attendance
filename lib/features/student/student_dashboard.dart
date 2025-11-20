import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Disable back button to login
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Student Dashboard"),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,

          // ✅ Logout Button Added
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              },
            ),
          ],
        ),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 30),

                _dashboardButton(
                  context,
                  icon: Icons.qr_code_scanner,
                  text: "Scan Attendance",
                  route: "/scan_attendance",
                ),

                const SizedBox(height: 16),

                _dashboardButton(
                  context,
                  icon: Icons.history,
                  text: "Attendance History",
                  route: "/attendance_history",
                ),

                const SizedBox(height: 30),

                Text(
                  "Logged in as Student",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dashboardButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String route,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 26),
        label: Text(text, style: const TextStyle(fontSize: 16)),
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
