import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;

  const AttendanceCard({
    required this.title,
    required this.subtitle,
    required this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool present = status.toLowerCase() == "present";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: present ? Colors.green : Colors.red,
          child: Text(
            status[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600),
        ),

        trailing: Text(
          status.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: present ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
