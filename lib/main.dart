import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Auth Screens
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';

// Faculty Screens
import 'features/faculty/faculty_dashboard.dart';
import 'features/faculty/create_session_screen.dart';
import 'features/faculty/attendance_analytics_screen.dart';
import 'features/faculty/session_report_screen.dart';
import 'features/faculty/session_history_calendar_screen.dart';

// Student Screens
import 'features/student/scan_attendance_screen.dart';
import 'features/student/attendance_history_screen.dart';

// Admin Screens
import 'features/admin/admin_dashboard.dart';
import 'features/admin/manage_users_screen.dart';
import 'features/admin/attendance_reports_screen.dart';
import 'features/admin/sessions_admin_screen.dart';
import 'features/admin/subjects_admin_screen.dart';
import 'features/admin/admin_analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart Attendance",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "Poppins",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),

      // FIRST SCREEN
      home: const WelcomeScreen(),

      routes: {
        // Auth Routes
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/dashboard': (_) => DashboardScreen(),

        // Faculty Routes
        '/faculty_dashboard': (_) => const FacultyDashboard(),
        '/create_session': (_) => const CreateSessionScreen(),
        '/analytics': (_) => const AttendanceAnalyticsScreen(),
        '/reports': (_) => const SessionReportScreen(),
        '/session_history_calendar': (_) => const SessionHistoryCalendarScreen(),

        // Student Routes
        '/scan_attendance': (_) => const ScanAttendanceScreen(),
        '/attendance_history': (_) => const AttendanceHistoryScreen(),

        // Admin Routes
        '/admin_dashboard': (_) => const AdminDashboard(),
        '/admin_manage_users': (_) => const ManageUsersScreen(),
        '/admin_reports': (_) => const AttendanceReportsScreen(),
        '/admin_sessions': (_) => const SessionsAdminScreen(),
        '/admin_subjects': (_) => const SubjectsAdminScreen(),
        '/admin_analytics': (_) => const AdminAnalyticsScreen(),
      },
    );
  }
}
