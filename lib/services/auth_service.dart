import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdgc_app/screens/home_screen.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser; // Getter for currentUser

  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _recordLoginEvent(result.user!.uid); // Ensure this method exists

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signUp(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _createUserDocument(result.user!);
        await _recordLoginEvent(result.user!.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'createdAt': Timestamp.now(),
      'lastLogin': Timestamp.now(),
      'loginCount': 1,
    });
  }

  Future<void> _recordLoginEvent(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': Timestamp.now(),
      'loginCount': FieldValue.increment(1),
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
