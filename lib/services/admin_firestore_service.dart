import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ----------------------------------------------------
  // USERS
  // ----------------------------------------------------
  Stream<QuerySnapshot> streamAllUsers() {
    return _db.collection('users').snapshots();
  }

  Future<void> addUser(Map<String, dynamic> data) async {
    await _db.collection('users').add(data);
  }

  Future<void> deleteUser(String id) async {
    await _db.collection('users').doc(id).delete();
  }

  // ----------------------------------------------------
  // SUBJECTS
  // ----------------------------------------------------
  Stream<QuerySnapshot> streamSubjects() {
    return _db.collection('subjects').snapshots();
  }

  Future<void> addSubject(Map<String, dynamic> data) async {
    await _db.collection('subjects').add({
      'name': data['name'],
      'code': data['code'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSubject(String id) async {
    await _db.collection('subjects').doc(id).delete();
  }

  // ----------------------------------------------------
  // SESSIONS
  // ----------------------------------------------------
  Stream<QuerySnapshot> streamAllSessions() {
    return _db
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .snapshots();
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

  // ----------------------------------------------------
  // ATTENDANCE
  // ----------------------------------------------------
  Stream<QuerySnapshot> getAttendanceReports() {
    return _db
        .collection('attendance')
        .orderBy('scannedAt', descending: true)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot>> fetchAttendanceForStudent(
      String studentId, DateTime from, DateTime to) async {
    final snap = await _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .where('scannedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('scannedAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .get();

    return snap.docs;
  }

  // ----------------------------------------------------
  // BASIC DASHBOARD ANALYTICS
  // ----------------------------------------------------
  Future<Map<String, dynamic>> basicAnalytics() async {
    final users = await _db.collection('users').get();
    final subjects = await _db.collection('subjects').get();
    final sessions = await _db.collection('sessions').get();
    final attendance = await _db.collection('attendance').get();

    return {
      'users': users.docs.length,
      'subjects': subjects.docs.length,
      'sessions': sessions.docs.length,
      'attendance': attendance.docs.length,
    };
  }
}
