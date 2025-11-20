// lib/services/admin_firestore_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AdminFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------- USERS ----------------
  Stream<List<QueryDocumentSnapshot>> streamAllUsers() {
    return _db
        .collection('users')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs);
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    await _db.collection('users').add({
      ...userData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(String docId, Map<String, dynamic> update) async {
    await _db.collection('users').doc(docId).update(update);
  }

  Future<void> deleteUser(String docId) async {
    await _db.collection('users').doc(docId).delete();
  }

  // ---------------- SUBJECTS ----------------
  Stream<List<QueryDocumentSnapshot>> streamSubjects() {
    return _db
        .collection('subjects')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs);
  }

  Future<void> addSubject(Map<String, dynamic> subject) async {
    await _db.collection('subjects').add({
      ...subject,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSubject(String id, Map<String, dynamic> update) async {
    await _db.collection('subjects').doc(id).update(update);
  }

  Future<void> deleteSubject(String id) async {
    await _db.collection('subjects').doc(id).delete();
  }

  // ---------------- SESSIONS (ADMIN VIEW) ----------------
  Stream<List<QueryDocumentSnapshot>> streamAllSessions() {
    return _db
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }

  Future<void> endSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).update({
      'qrActive': false,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).delete();
  }

  // ---------------- REPORTS ----------------
  Future<List<QueryDocumentSnapshot>> fetchAttendanceForStudent(
      String studentId, DateTime from, DateTime to) async {
    final snap = await _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .where('scannedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('scannedAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .orderBy('scannedAt', descending: true)
        .get();

    return snap.docs;
  }

  Future<List<QueryDocumentSnapshot>> fetchAttendanceForSession(
      String sessionId) async {
    final snap = await _db
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('scannedAt')
        .get();

    return snap.docs;
  }

  // ---------------- GENERATE CSV ----------------
  Future<String> generateSessionCsv(String sessionId) async {
    final attendance = await fetchAttendanceForSession(sessionId);

    final rows = <List<String>>[];
    rows.add(['StudentId', 'StudentName', 'Status', 'ScannedAt']);

    for (var doc in attendance) {
      final d = doc.data() as Map<String, dynamic>;
      final scannedAt = (d['scannedAt'] as Timestamp?)?.toDate();
      final scannedStr = scannedAt != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(scannedAt)
          : '';

      rows.add([
        d['studentId'] ?? '',
        d['studentName'] ?? '',
        d['status'] ?? '',
        scannedStr,
      ]);
    }

    final csv = StringBuffer();
    for (var row in rows) {
      csv.writeln(
          row.map((c) => '"${c.toString().replaceAll('"', '""')}"').join(','));
    }

    return csv.toString();
  }

  // ---------------- ANALYTICS ----------------
  Future<Map<String, int>> basicAnalytics() async {
    final users = await _db.collection('users').get();
    final sessions = await _db.collection('sessions').get();
    final attendance = await _db.collection('attendance').get();

    final studentCount =
        users.docs.where((d) => d['role'] == 'student').length;
    final facultyCount =
        users.docs.where((d) => d['role'] == 'professor').length;

    return {
      'students': studentCount,
      'faculty': facultyCount,
      'sessions': sessions.docs.length,
      'attendance': attendance.docs.length,
    };
  }
}
