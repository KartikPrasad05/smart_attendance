// lib/firebase/auth_methods.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AuthMethods: signUp, login, getProfile, signOut
/// - Stores central users collection
/// - Creates role-specific profile documents in students / professors / admins
/// - Returns structured results and clear error messages

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Register a new user and create role-specific profile data
  /// extraProfile used for student/professor fields (rollNumber, department, year, employeeId)
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String role, // one of: admin|professor|student (case-insensitive)
    Map<String, dynamic>? extraProfile,
  }) async {
    try {
      final normalizedRole = role.toLowerCase();
      if (!['admin', 'professor', 'student'].contains(normalizedRole)) {
        return {'success': false, 'message': 'Invalid role'};
      }

      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;

      // Central user doc
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': normalizedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Role-specific documents
      if (normalizedRole == 'student') {
        await _db.collection('students').doc(uid).set({
          'userId': uid,
          'name': name,
          'rollNumber': extraProfile?['rollNumber'] ?? '',
          'department': extraProfile?['department'] ?? '',
          'year': extraProfile?['year'] ?? 1,
          'classGroupId': extraProfile?['classGroupId'] ?? null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (normalizedRole == 'professor') {
        await _db.collection('professors').doc(uid).set({
          'userId': uid,
          'name': name,
          'employeeId': extraProfile?['employeeId'] ?? '',
          'department': extraProfile?['department'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (normalizedRole == 'admin') {
        await _db.collection('admins').doc(uid).set({
          'userId': uid,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return {'success': true, 'uid': uid, 'role': normalizedRole};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Auth error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Login user with email/password
  /// Returns {success: true, uid, role} on success (role fetched from users doc)
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        // In case user created via Console, create a default user doc
        return {'success': true, 'uid': uid, 'role': null};
      }
      final role = (doc.data()!['role'] as String?)?.toLowerCase();
      return {'success': true, 'uid': uid, 'role': role};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Returns the current user's full profile from `users` collection
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return {'uid': user.uid, 'name': data['name'], 'email': data['email'], 'role': data['role']};
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Helper: fetch role quickly
  Future<String?> fetchRoleForUid(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return (doc.data()!['role'] as String?)?.toLowerCase();
  }
}
