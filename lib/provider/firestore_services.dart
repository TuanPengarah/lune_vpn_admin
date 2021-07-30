import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  Future<String?> createNews(
      String? title, String? subtitle, String? content) async {
    String? status;
    Map<String, dynamic> data = {
      'Title': title,
      'Subtitle': subtitle,
      'Content': content,
      'Tarikh': FieldValue.serverTimestamp(),
    };
    _firestore.collection('News').add(data).then((value) {
      status = 'operation-completed';
    }).onError((error, stackTrace) {
      status = error.toString();
    });

    return status;
  }

  Future<String?> deleteNews(String uid) async {
    String? status;
    _firestore.collection('News').doc(uid).delete().then((value) {
      status = 'operation-completed';
    }).onError((error, stackTrace) {
      status = error.toString();
    });
    return status;
  }
}
