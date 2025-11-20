// lib/features/faculty/attendance_analytics_screen.dart
import 'package:flutter/material.dart';
import '../../services/session_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceAnalyticsScreen extends StatefulWidget {
  final String? initialSessionId;
  const AttendanceAnalyticsScreen({super.key, this.initialSessionId});

  @override
  State<AttendanceAnalyticsScreen> createState() => _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState extends State<AttendanceAnalyticsScreen> {
  final SessionFirestoreService _service = SessionFirestoreService();
  String? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _selectedSessionId = widget.initialSessionId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Analytics"), backgroundColor: Colors.deepPurple),
      body: Column(
        children: [
          StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: _service.sessionsForCurrentProfessor(),
            builder: (context, snap) {
              final docs = snap.data ?? [];
              return Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  value: _selectedSessionId,
                  items: docs.map((d) {
                    final id = d.id;
                    final map = d.data() as Map<String, dynamic>;
                    final subject = map['subjectId'] ?? 'Subject';
                    return DropdownMenuItem(value: id, child: Text("$subject • $id"));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedSessionId = v),
                  decoration: const InputDecoration(labelText: "Select Session"),
                ),
              );
            },
          ),
          Expanded(
            child: _selectedSessionId == null
                ? const Center(child: Text("Select a session to view analytics"))
                : FutureBuilder<Map<String,int>>(
                    future: _service.getSessionAttendanceCounts(_selectedSessionId!),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      final m = snap.data ?? {'present':0,'absent':0,'total':0};
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Card(child: ListTile(title: const Text("Total students"), trailing: Text("${m['total']}"))),
                            const SizedBox(height: 8),
                            Card(child: ListTile(title: const Text("Present"), trailing: Text("${m['present']}"))),
                            const SizedBox(height: 8),
                            Card(child: ListTile(title: const Text("Absent"), trailing: Text("${m['absent']}"))),
                            const SizedBox(height: 16),
                            Expanded(child: StreamBuilder<List<QueryDocumentSnapshot>>(stream: _service.attendanceForSession(_selectedSessionId!), builder: (c,s) {
                              final docs = s.data ?? [];
                              if (docs.isEmpty) return const Center(child: Text("No attendance records for this session"));
                              return ListView.builder(itemCount: docs.length, itemBuilder: (_,i){
                                final d = docs[i].data() as Map<String,dynamic>;
                                final ts = d['timestamp'];
                                final when = ts is Timestamp ? ts.toDate() : DateTime.now();
                                return ListTile(title: Text(d['studentId'] ?? ''), subtitle: Text(when.toString()), trailing: Text((d['status'] ?? '').toString().toUpperCase()));
                              });
                            })),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
