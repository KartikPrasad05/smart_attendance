// lib/features/faculty/session_report_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/session_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionReportScreen extends StatefulWidget {
  const SessionReportScreen({super.key});

  @override
  State<SessionReportScreen> createState() => _SessionReportScreenState();
}

class _SessionReportScreenState extends State<SessionReportScreen> {
  final SessionFirestoreService _service = SessionFirestoreService();
  String? _sessionId;
  String? _csv;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate Report"), backgroundColor: Colors.deepPurple),
      body: Column(
        children: [
          StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: _service.sessionsForCurrentProfessor(),
            builder: (context, snap) {
              final docs = snap.data ?? [];
              return Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  value: _sessionId,
                  items: docs.map((d) => DropdownMenuItem(value: d.id, child: Text("${(d.data() as Map)['subjectId'] ?? 'Subject'} • ${d.id}"))).toList(),
                  onChanged: (v) => setState(() => _sessionId = v),
                  decoration: const InputDecoration(labelText: "Select Session"),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: _sessionId == null || _loading ? null : () async {
              setState(() => _loading = true);
              final csv = await _service.generateSessionCsv(_sessionId!);
              setState(() { _csv = csv; _loading = false; });
              await Clipboard.setData(ClipboardData(text: csv));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("CSV copied to clipboard")));
            },
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Generate & Copy CSV"),
          ),
          const SizedBox(height: 12),
          if (_csv != null) Expanded(child: Padding(padding: const EdgeInsets.all(12), child: SingleChildScrollView(child: SelectableText(_csv!)))),
        ],
      ),
    );
  }
}
