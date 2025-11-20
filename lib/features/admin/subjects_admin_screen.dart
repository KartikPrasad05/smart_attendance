// lib/features/admin/subjects_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_firestore_service.dart';

class SubjectsAdminScreen extends StatefulWidget {
  const SubjectsAdminScreen({super.key});
  @override
  State<SubjectsAdminScreen> createState() => _SubjectsAdminScreenState();
}

class _SubjectsAdminScreenState extends State<SubjectsAdminScreen> {
  final AdminFirestoreService _service = AdminFirestoreService();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  void _showAdd() {
    _nameCtrl.clear();
    _codeCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Subject'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'Code')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            final name = _nameCtrl.text.trim();
            final code = _codeCtrl.text.trim();
            if (name.isEmpty) return;
            await _service.addSubject({'name': name, 'code': code});
            Navigator.pop(context);
          }, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects'), backgroundColor: Colors.deepPurple),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.deepPurple, child: const Icon(Icons.add), onPressed: _showAdd),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _service.streamSubjects(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!;
          if (docs.isEmpty) return const Center(child: Text('No subjects'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(d['name'] ?? ''),
                subtitle: Text(d['code'] ?? ''),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _service.deleteSubject(docs[i].id)),
              );
            },
          );
        },
      ),
    );
  }
}
