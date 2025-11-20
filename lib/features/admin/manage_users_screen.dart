// lib/features/admin/manage_users_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_firestore_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});
  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final AdminFirestoreService _service = AdminFirestoreService();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _role = 'student';

  void _showAddDialog() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _role = 'student';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'professor', child: Text('Professor')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (v) => _role = v ?? 'student',
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = _nameCtrl.text.trim();
              final email = _emailCtrl.text.trim();
              if (name.isEmpty || email.isEmpty) return;
              await _service.addUser({'name': name, 'email': email, 'role': _role});
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async { await _service.deleteUser(id); Navigator.pop(context); }, child: const Text('Delete')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users'), backgroundColor: Colors.deepPurple),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _service.streamAllUsers(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!;
          if (docs.isEmpty) return const Center(child: Text('No users found'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(child: Text((d['name'] ?? 'U').toString()[0].toUpperCase())),
                title: Text(d['name'] ?? ''),
                subtitle: Text('${d['email'] ?? ''} • ${d['role'] ?? ''}'),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(docs[i].id)),
              );
            },
          );
        },
      ),
    );
  }
}
