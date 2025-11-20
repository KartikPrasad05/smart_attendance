import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// LOGIN USER
  Future<String?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure user exists in Firestore
      await _ensureUserDoc(result.user!);

      return null; // null means SUCCESS
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// REGISTER USER
  Future<String?> register(String email, String password, String role) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection("users").doc(result.user!.uid).set({
        "email": email,
        "role": role,
        "created_at": FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  /// GET ROLE OF LOGGED-IN USER
  Future<String> getRole() async {
    final user = _auth.currentUser;
    if (user == null) return "guest";

    final doc = await _db.collection("users").doc(user.uid).get();

    if (!doc.exists) {
      // fallback to student
      return "student";
    }

    return doc.data()?["role"] ?? "student";
  }

  /// LOGOUT USER
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// PRIVATE: ensure a firestore doc exists
  Future<void> _ensureUserDoc(User user) async {
    final doc = await _db.collection("users").doc(user.uid).get();

    if (!doc.exists) {
      await _db.collection("users").doc(user.uid).set({
        "email": user.email,
        "role": "student", // auto fallback
        "created_at": FieldValue.serverTimestamp(),
      });
    }
  }
}
