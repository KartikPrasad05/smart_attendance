// lib/features/faculty/session_management_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_firestore_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SessionManagementScreen extends StatefulWidget {
  const SessionManagementScreen({super.key});

  @override
  State<SessionManagementScreen> createState() =>
      _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {
  final SessionFirestoreService _service = SessionFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        backgroundColor: Colors.deepPurple,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _service.sessionsForCurrentProfessorStream(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // No sessions
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Sessions Found.\nCreate your first session!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final sessions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final doc = sessions[index];
              final data = doc.data() as Map<String, dynamic>;

              final sessionId = doc.id;
              final subject = data["subjectId"] ?? "Unknown Subject";
              final pin = data["pin"] ?? "";
              final active = data["qrActive"] == true;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  title: Text(subject),
                  subtitle: Text("Session ID: $sessionId"),

                  children: [
                    // QR + PIN (only when active)
                    if (active) ...[
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            QrImageView(
                              data: "$sessionId|$pin",
                              size: 180,
                              version: QrVersions.auto,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "PIN: $pin",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],

                    // Attendance List Section
                    StreamBuilder<QuerySnapshot>(
                      stream: _service.attendanceStream(sessionId),
                      builder: (context, aSnap) {
                        if (aSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final attendance = aSnap.data?.docs ?? [];

                        final presentCount = attendance.where((e) {
                          final d = e.data() as Map<String, dynamic>;
                          return d["status"] == "present";
                        }).length;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Present: $presentCount",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),

                              // End Session Button
                              ElevatedButton(
                                onPressed: active
                                    ? () async {
                                        await _service.endSession(sessionId);
                                        if (!mounted) return;

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text("Session Ended"),
                                        ));
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: active
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                ),
                                child: Text(
                                  active ? "End Session" : "Ended",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
