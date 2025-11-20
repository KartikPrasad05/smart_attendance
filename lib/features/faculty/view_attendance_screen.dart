import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAttendanceScreen extends StatefulWidget {
  final String sessionId;
  final String subjectName;

  const ViewAttendanceScreen({
    required this.sessionId,
    required this.subjectName,
    super.key,
  });

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  bool loading = false;

  Stream<QuerySnapshot> attendanceStream() {
    return db
        .collection("attendance")
        .where("session_id", isEqualTo: widget.sessionId)
        .orderBy("scanned_at", descending: false)
        .snapshots();
  }

  Future<void> _updateStatus(String docId, String status) async {
    setState(() => loading = true);

    try {
      await db.collection("attendance").doc(docId).update({
        "status": status,
        "updated_at": FieldValue.serverTimestamp(),
      });

      // audit log
      await db.collection("audit_logs").add({
        "action": "manual_edit",
        "session_id": widget.sessionId,
        "attendance_id": docId,
        "new_status": status,
        "actor_uid": auth.currentUser?.uid ?? "unknown",
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Status updated")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: $e")));
    }

    setState(() => loading = false);
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.event_busy, size: 80, color: Colors.deepPurple),
          SizedBox(height: 12),
          Text(
            "No attendance recorded",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Attendance — ${widget.subjectName}"),
      ),

      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: attendanceStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return _emptyState();
              }

              final docs = snap.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final data = docs[i].data() as Map<String, dynamic>;

                  final docId = docs[i].id;
                  final studentId = data["student_id"] ?? "Unknown";
                  final ts = data["scanned_at"] as Timestamp?;
                  final scanned = ts != null ? dateFormat.format(ts.toDate()) : "-";

                  final status = (data["status"] ?? "present") as String;
                  final isPresent = status == "present";

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          studentId.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      title: Text(studentId),
                      subtitle: Text("Scanned: $scanned"),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPresent ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (val) => _updateStatus(docId, val),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: "present", child: Text("Mark Present")),
                              PopupMenuItem(
                                  value: "absent", child: Text("Mark Absent")),
                              PopupMenuItem(
                                value: "excused",
                                child: Text("Mark Excused"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          if (loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.12),
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
        ],
      ),
    );
  }
}
