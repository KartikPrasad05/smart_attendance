// lib/features/faculty/session_history_calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/session_firestore_service.dart';

class SessionHistoryCalendarScreen extends StatefulWidget {
  const SessionHistoryCalendarScreen({super.key});

  @override
  State<SessionHistoryCalendarScreen> createState() =>
      _SessionHistoryCalendarScreenState();
}

class _SessionHistoryCalendarScreenState
    extends State<SessionHistoryCalendarScreen> {
  DateTime? from;
  DateTime? to;

  final SessionFirestoreService _service = SessionFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session History"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          _dateSelector(),
          Expanded(child: _sessionListView()),
        ],
      ),
    );
  }

  // ---------------------------
  // DATE RANGE SELECTOR
  // ---------------------------
  Widget _dateSelector() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: from ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => from = d);
              },
              child: Text(
                  from == null ? "From" : from!.toString().split(" ")[0]),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: to ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => to = d);
              },
              child:
                  Text(to == null ? "To" : to!.toString().split(" ")[0]),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // SESSION LIST VIEW
  // ---------------------------
  Widget _sessionListView() {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _service.sessionsForCurrentProfessor(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data ?? [];

        // FILTER BY DATE RANGE
        final filtered = docs.where((doc) {
          final map = doc.data() as Map<String, dynamic>;
          final Timestamp? ts = map["createdAt"] as Timestamp?;

          if (ts == null) return false;
          final dt = ts.toDate();

          if (from != null &&
              dt.isBefore(DateTime(from!.year, from!.month, from!.day))) {
            return false;
          }

          if (to != null &&
              dt.isAfter(DateTime(to!.year, to!.month, to!.day, 23, 59, 59))) {
            return false;
          }

          return true;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "No sessions found for selected date range",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final doc = filtered[i];
            final m = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            final subject = m["subjectId"] ?? "Unknown Subject";
            final created =
                (m["createdAt"] as Timestamp).toDate().toString().split(".")[0];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(
                  subject,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  "Session ID: $id\nCreated: $created",
                  style: const TextStyle(fontSize: 13),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
