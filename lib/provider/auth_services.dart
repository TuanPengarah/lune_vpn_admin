import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthenticationServices extends ChangeNotifier {
  final FirebaseAuth _auth;
  AuthenticationServices(this._auth);

  Future<String?> createUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int money,
    required bool isAgent,
    required bool isAdmin,
  }) async {
    String? status;
    FirebaseApp app = await Firebase.initializeApp(
      name: 'secondary',
      options: Firebase.app().options,
    );
    try {
      await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((credential) async {
        String uid = credential.user!.uid;
        Map<String, dynamic> data = {
          'Name': name,
          'Phone': phone,
          'Email': email,
          'Money': money,
          'isAgent': isAgent,
        };
        isAdmin == false
            ? await FirebaseFirestore.instance
                .collection('Agent')
                .doc(uid)
                .set(data)
            : await FirebaseFirestore.instance
                .collection('userAdmin')
                .doc(uid)
                .set(data);
        await app.delete();
        status = 'operation-completed';
      });
    } on FirebaseAuthException catch (e) {
      status = e.toString();
      await app.delete();
    }
    return status;
  }

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
