import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // สำหรับ Login
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // สำหรับ Register
  Future<String?> registerUser({
    required String email,
    required String password,
    required String phoneNumber,
    bool isBusiness = false,
    Map<String, String>? businessData,
    required String username,
  }) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (result.user != null) {
        // Create user document in Firestore
        await _firestore.collection('User').doc(result.user!.uid).set({
          'user_id': result.user!.uid,
          'email': email,
          'phoneNumber': phoneNumber,
          'isBusiness': isBusiness,
          'createdAt': FieldValue.serverTimestamp(),
          'username': username, // เพิ่มบรรทัดนี้
          ...isBusiness ? businessData ?? {} : {},
        });

        return null; // Return null means success
      }

      return 'Registration failed'; // Should not reach here normally
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak';
        case 'email-already-in-use':
          return 'The account already exists for that email';
        case 'invalid-email':
          return 'The email address is not valid';
        default:
          return e.message ?? 'An unknown error occurred';
      }
    } catch (e) {
      return e.toString();
    }
  }
}
