// lib/firebase/firestore_methods.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMethods {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create Subject doc
  Future<String> createSubject({
    required String name,
    required String code,
    required String professorUid,
    int semester = 1,
    String department = '',
  }) async {
    final ref = _db.collection('subjects').doc();
    await ref.set({
      'id': ref.id,
      'name': name,
      'code': code,
      'professorUid': professorUid,
      'semester': semester,
      'department': department,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Simple session creation (client-side). Prefer calling cloud function createSession for signed QR flow.
  Future<String> createSessionSimple({
    required String subjectId,
    required String subjectName,
    required String generatedByUid,
    String? classGroupId,
    int durationSeconds = 120,
  }) async {
    final ref = _db.collection('sessions').doc();
    final now = DateTime.now();
    await ref.set({
      'id': ref.id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'classGroupId': classGroupId ?? null,
      'generatedBy': generatedByUid,
      'createdAt': FieldValue.serverTimestamp(),
      'startAt': now.toIso8601String(),
      'expiresAt': DateTime.now().add(Duration(seconds: durationSeconds)).toIso8601String(),
      'qrActive': true,
    });
    return ref.id;
  }

  /// Get students in a classGroup
  Stream<QuerySnapshot> studentsInClassGroup(String classGroupId) {
    return _db.collection('students').where('classGroupId', isEqualTo: classGroupId).snapshots();
  }

  /// Mark attendance (helper) - NOTE: prefer cloud function for security
  Future<void> markAttendanceLocal({
    required String sessionId,
    required String studentUid,
    String status = 'present',
    Map<String, dynamic>? geo,
    Map<String, dynamic>? deviceInfo,
  }) async {
    final ref = _db.collection('attendance').doc();
    await ref.set({
      'id': ref.id,
      'sessionId': sessionId,
      'studentUid': studentUid,
      'scannedAt': FieldValue.serverTimestamp(),
      'status': status,
      'geo': geo ?? null,
      'deviceInfo': deviceInfo ?? null,
    });
  }

  /// Fetch attendance for a session
  Stream<QuerySnapshot> attendanceForSession(String sessionId) {
    return _db.collection('attendance').where('sessionId', isEqualTo: sessionId).orderBy('scannedAt', descending: false).snapshots();
  }
}
