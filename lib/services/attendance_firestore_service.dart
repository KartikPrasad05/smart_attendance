// lib/services/session_firestore_service.dart
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionFirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Create session with PIN and expiry
  Future<String?> createSession({
    required String subjectId,
    required int durationSeconds,
    String? classGroupId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final pin = _generatePin();
    final now = DateTime.now();
    final expires = now.add(Duration(seconds: durationSeconds));

    final doc = await _db.collection('sessions').add({
      'subjectId': subjectId,
      'classGroupId': classGroupId ?? '',
      'generatedBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expires),
      'durationSeconds': durationSeconds,
      'qrActive': true,
      'pin': pin,
    });

    return doc.id;
  }

  // End session
  Future<void> endSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).update({
      'qrActive': false,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream of sessions by professor (QueryDocumentSnapshot list)
  Stream<List<QueryDocumentSnapshot>> sessionsForCurrentProfessor() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('sessions')
        .where('generatedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }

  // Stream of attendance docs for a session
  Stream<List<QueryDocumentSnapshot>> attendanceForSession(String sessionId) {
    return _db
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }

  // Get counts for a session (present, absent, total)
  Future<Map<String, int>> getSessionAttendanceCounts(String sessionId) async {
    final snap = await _db
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .get();

    final docs = snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
    final present = docs.where((m) => (m['status'] ?? '') == 'present').length;
    final total = docs.length;
    final absent = total - present;
    return {'present': present, 'absent': absent, 'total': total};
  }

  // Simple overview for faculty dashboard (total sessions, active sessions, total present across sessions, unique students)
  Stream<Map<String, int>> getProfessorOverview() {
    final uid = _auth.currentUser!.uid;
    // Listen to sessions created by this prof and their attendance snapshot changes
    final sessionsStream = _db
        .collection('sessions')
        .where('generatedBy', isEqualTo: uid)
        .snapshots();

    return sessionsStream.asyncMap((sessionSnap) async {
      final sessions = sessionSnap.docs;
      final totalSessions = sessions.length;
      final activeSessions = sessions.where((d) => d.data()['qrActive'] == true).length;

      // gather session ids
      final sessionIds = sessions.map((d) => d.id).toList();
      if (sessionIds.isEmpty) {
        return {
          'totalSessions': totalSessions,
          'activeSessions': activeSessions,
          'totalPresent': 0,
          'totalStudents': 0,
        };
      }

      // query attendance for these sessions in one go (Firestore has 'in' operator)
      final attendanceSnap = await _db
          .collection('attendance')
          .where('sessionId', whereIn: sessionIds.take(10).toList()) // Firestore 'in' limit; take 10 as safe
          .get();

      final allDocs = attendanceSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
      final totalPresent = allDocs.where((m) => (m['status'] ?? '') == 'present').length;
      final uniqueStudents = allDocs.map((m) => m['studentId'] as String?).whereType<String>().toSet().length;

      return {
        'totalSessions': totalSessions,
        'activeSessions': activeSessions,
        'totalPresent': totalPresent,
        'totalStudents': uniqueStudents,
      };
    });
  }

  // Generate printable CSV string for a session (simple)
  Future<String> generateSessionCsv(String sessionId) async {
    final attendanceSnap = await _db
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('timestamp', descending: false)
        .get();

    final rows = <List<String>>[];
    rows.add(['studentId', 'status', 'timestamp', 'subjectId', 'extra']); // header

    for (final doc in attendanceSnap.docs) {
      final data = doc.data();
      final ts = data['timestamp'];
      final tsMs = ts is int ? ts : (ts is Timestamp ? ts.millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch);
      rows.add([
        data['studentId'] ?? '',
        data['status'] ?? '',
        DateTime.fromMillisecondsSinceEpoch(tsMs).toIso8601String(),
        data['subjectId'] ?? '',
        data['note'] ?? '',
      ]);
    }

    // build CSV
    final sb = StringBuffer();
    for (final r in rows) {
      sb.writeln(r.map((c) => '"${c.toString().replaceAll('"', '""')}"').join(','));
    }
    return sb.toString();
  }

  String _generatePin() {
    final rnd = Random();
    final n = rnd.nextInt(9000) + 1000; // 1000..9999
    return n.toString();
  }
}
