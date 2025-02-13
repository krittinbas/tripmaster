import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String email,
    required String password,
    required String phoneNumber,
    required String username,
    bool isBusiness = false,
    String? businessName,
    String? businessType,
    String? businessAddress,
    String? taxId,
  }) async {
    // Validate basic input data
    if (email.trim().isEmpty ||
        password.isEmpty ||
        phoneNumber.trim().isEmpty ||
        username.trim().isEmpty) {
      return 'Please fill in all required fields';
    }

    // Validate business data if it's a business account
    if (isBusiness) {
      if (businessName == null ||
          businessName.trim().isEmpty ||
          businessType == null ||
          businessType.trim().isEmpty ||
          businessAddress == null ||
          businessAddress.trim().isEmpty ||
          taxId == null ||
          taxId.trim().isEmpty) {
        return 'Please fill in all business information';
      }
    }

    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Prepare user data
      final userData = {
        'business_id': isBusiness ? userId : null,
        'email': email.trim(),
        'phonenumber': phoneNumber.trim(),
        'user_bio': null,
        'user_follower': 0,
        'user_following': 0,
        'user_id': userId,
        'user_title': null,
        'user_triptaken': 0,
        'username': username.trim(),
        'created_at': FieldValue.serverTimestamp(),
      };

      // Create user document
      await _firestore.collection('User').doc(userId).set(userData);

      // Create business document if needed
      if (isBusiness &&
          businessName != null &&
          businessType != null &&
          businessAddress != null &&
          taxId != null) {
        final businessData = {
          'business_id': userId,
          'business_name': businessName.trim(),
          'business_type': businessType.trim(),
          'business_address': businessAddress.trim(),
          'tax_id': taxId.trim(),
          'created_at': FieldValue.serverTimestamp(),
          'user_id': userId,
          'status': 'active',
        };

        await _firestore.collection('Business').doc(userId).set(businessData);
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      print('Registration error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }
}
