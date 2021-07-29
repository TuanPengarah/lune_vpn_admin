import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationServices extends ChangeNotifier {
  final FirebaseAuth _auth;
  AuthenticationServices(this._auth);

  Future<String?> signIn(String email, String password) async {
    String? status;
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => status = 'completed');
    } on FirebaseAuthException catch (e) {
      print(e.code);
      status = e.code;
    }
    return status;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
