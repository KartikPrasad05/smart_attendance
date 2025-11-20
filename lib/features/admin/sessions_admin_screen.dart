// lib/features/admin/sessions_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_firestore_service.dart';

class SessionsAdminScreen extends StatefulWidget {
  const SessionsAdminScreen({super.key});
  @override
  State<SessionsAdminScreen> createState() => _SessionsAdminScreenState();
}

class _SessionsAdminScreenState extends State<SessionsAdminScreen> {
  final AdminFirestoreService _service = AdminFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions'), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _service.streamAllSessions(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!;
          if (docs.isEmpty) return const Center(child: Text('No sessions found'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final id = docs[i].id;
              final d = docs[i].data() as Map<String, dynamic>;
              final active = d['qrActive'] == true;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(d['subjectId'] ?? 'Subject'),
                  subtitle: Text('By: ${d['generatedBy'] ?? ''}\nCreated: ${d['createdAt'] ?? ''}'),
                  trailing: Wrap(spacing: 6, children: [
                    IconButton(icon: const Icon(Icons.stop_circle, color: Colors.orange), onPressed: active ? () => _service.endSession(id) : null),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _service.deleteSession(id)),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
