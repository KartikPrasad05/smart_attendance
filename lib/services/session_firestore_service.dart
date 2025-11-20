// lib/services/session_firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionFirestoreService {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// ==========================================================
  /// CREATE SESSION (Faculty)
  /// ==========================================================
  Future<String?> createSession({
    required String subjectId,
    required int durationSeconds,
    required String pin,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final sessionId = "${DateTime.now().millisecondsSinceEpoch}";
    final expiresAt = DateTime.now().add(Duration(seconds: durationSeconds));

    await _fire.collection("sessions").doc(sessionId).set({
      "sessionId": sessionId,
      "subjectId": subjectId,
      "facultyId": user.uid,
      "createdAt": DateTime.now(),
      "expiresAt": expiresAt,
      "qrActive": true,
      "pin": pin,
    });

    return sessionId;
  }

  /// ==========================================================
  /// FACULTY: STREAM — My Sessions
  /// ==========================================================
  Stream<List<QueryDocumentSnapshot>> sessionsForCurrentProfessor() {
    final user = _auth.currentUser;

    return _fire
        .collection("sessions")
        .where("facultyId", isEqualTo: user?.uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs);
  }

  /// ==========================================================
  /// END SESSION (Disable QR Scan)
  /// ==========================================================
  Future<void> endSession(String sessionId) async {
    await _fire.collection("sessions").doc(sessionId).update({
      "qrActive": false,
    });
  }

  /// ==========================================================
  /// PIN VERIFICATION (Student)
  /// ==========================================================
  Future<bool> verifyPin({
    required String sessionId,
    required String pin,
  }) async {
    final doc = await _fire.collection("sessions").doc(sessionId).get();
    if (!doc.exists) return false;

    return doc["pin"] == pin;
  }

  /// ==========================================================
  /// MARK ATTENDANCE (After PIN Verified)
  /// ==========================================================
  Future<String> markAttendance({
    required String sessionId,
    required String uid,
  }) async {
    final sessionDoc =
        await _fire.collection("sessions").doc(sessionId).get();

    if (!sessionDoc.exists) return "Session does not exist";

    if (sessionDoc["qrActive"] != true) return "Session expired";

    await _fire.collection("attendance").doc("$sessionId-$uid").set({
      "sessionId": sessionId,
      "studentId": uid,
      "scannedAt": DateTime.now(),
      "status": "present",
    });

    return "Success";
  }

  /// ==========================================================
  /// STREAM — Attendance list for a session
  /// ==========================================================
  Stream<List<QueryDocumentSnapshot>> attendanceForSession(
      String sessionId) {
    return _fire
        .collection("attendance")
        .where("sessionId", isEqualTo: sessionId)
        .snapshots()
        .map((snap) => snap.docs);
  }

  /// ==========================================================
  /// ANALYTICS — Count Present Students
  /// ==========================================================
  Future<Map<String, int>> getSessionAttendanceCounts(
      String sessionId) async {
    final snap = await _fire
        .collection("attendance")
        .where("sessionId", isEqualTo: sessionId)
        .get();

    int present =
        snap.docs.where((d) => d["status"] == "present").length;

    return {"present": present};
  }

  /// ==========================================================
  /// CSV EXPORT (ADMIN & FACULTY)
  /// ==========================================================
  Future<String> generateSessionCsv(String sessionId) async {
    final sessionSnap =
        await _fire.collection("sessions").doc(sessionId).get();

    final attendSnap = await _fire
        .collection("attendance")
        .where("sessionId", isEqualTo: sessionId)
        .get();

    final StringBuffer csv = StringBuffer();

    csv.writeln("Session ID,Student ID,Timestamp,Status");

    for (var d in attendSnap.docs) {
      csv.writeln(
        "$sessionId,${d['studentId']},${d['scannedAt']},${d['status']}",
      );
    }

    return csv.toString();
  }

  // ================================================================
  // ADMIN EXTRA FUNCTIONS
  // ================================================================

  /// ADMIN: All sessions
  Stream<List<QueryDocumentSnapshot>> getAllSessions() {
    return _fire
        .collection("sessions")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs);
  }

  /// ADMIN: All attendance
  Stream<List<QueryDocumentSnapshot>> getAllAttendance() {
    return _fire
        .collection("attendance")
        .orderBy("scannedAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs);
  }

  /// ADMIN: Sessions by date (for calendar)
  Stream<List<QueryDocumentSnapshot>> getSessionsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _fire
        .collection("sessions")
        .where("createdAt", isGreaterThanOrEqualTo: start)
        .where("createdAt", isLessThan: end)
        .snapshots()
        .map((snap) => snap.docs);
  }

  /// ADMIN: Attendance by session
  Stream<List<QueryDocumentSnapshot>> getAttendanceBySession(
      String sessionId) {
    return _fire
        .collection("attendance")
        .where("sessionId", isEqualTo: sessionId)
        .snapshots()
        .map((snap) => snap.docs);
  }
}
