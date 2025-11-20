// lib/features/admin/attendance_reports_screen.dart
import 'package:flutter/material.dart';
import '../../services/admin_firestore_service.dart';
import 'package:intl/intl.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({super.key});
  @override
  State<AttendanceReportsScreen> createState() => _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  final AdminFirestoreService _service = AdminFirestoreService();
  final _studentCtrl = TextEditingController();
  DateTimeRange? _range;

  void _pickRange() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(context: context, firstDate: DateTime(now.year - 3), lastDate: DateTime(now.year + 1));
    if (r != null) setState(() => _range = r);
  }

  Future<void> _generate() async {
    final studentId = _studentCtrl.text.trim();
    if (studentId.isEmpty || _range == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter student id and date range')));
      return;
    }
    final from = _range!.start;
    final to = _range!.end.add(const Duration(hours: 23, minutes: 59));
    final docs = await _service.fetchAttendanceForStudent(studentId, from, to);
    if (docs.isEmpty) {
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('No Data'), content: const Text('No attendance found')));
      return;
    }

    // show basic list
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text('Attendance'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final ts = (data['scannedAt'] as Timestamp?)?.toDate();
              final str = ts != null ? DateFormat('yyyy-MM-dd HH:mm').format(ts) : '';
              return ListTile(title: Text(data['status'] ?? ''), subtitle: Text(str));
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final rangeStr = _range == null ? 'Pick date range' : '${DateFormat.yMd().format(_range!.start)} - ${DateFormat.yMd().format(_range!.end)}';
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Reports'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: _studentCtrl, decoration: const InputDecoration(labelText: 'Student ID (document id or roll)')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: _pickRange, child: Text(rangeStr))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _generate, child: const Text('Generate')),
            ]),
          ],
        ),
      ),
    );
  }
}
