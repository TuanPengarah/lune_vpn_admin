import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

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

  Future<int?> userTopup(int topup, String? uid) async {
    int? money;
    DocumentReference ref = _firestore.collection('Agent').doc(uid);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot? snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      int moneyCount = snapshot.get('Money') + topup;

      transaction.update(
        ref,
        {
          'Money': moneyCount,
        },
      );
      money = moneyCount;
      return moneyCount;
    });
    return money;
  }

  Future<String?> deleteUser(String? uid) async {
    String? status;
    await _firestore
        .collection('Agent')
        .doc(uid)
        .delete()
        .then((value) => status = 'operation-completed')
        .catchError(
          (error) => status = error.toString(),
        );

    return status;
  }

  Future<String?> acceptOrder({
    required String? userUID,
    required String? vpnUID,
    required String remarks,
    required String duration,
    required int vpnPrice,
  }) async {
    String? status;
    String? vpnEnd;
    DocumentReference refVPN = _firestore
        .collection('Agent')
        .doc(userUID)
        .collection('Order')
        .doc(vpnUID);

    DocumentReference refUser = _firestore.collection('Agent').doc(userUID);

    //convert duration to date object
    if (duration == '1 Days Free Trial') {
      var dur = Jiffy()..add(duration: Duration(days: 1));
      vpnEnd = dur.format('d/MM/yyyy').toString();
    } else if (duration == '15 Days (RM5)') {
      var dur = Jiffy()..add(duration: Duration(days: 15));
      vpnEnd = dur.format('d/MM/yyyy').toString();
    } else if (duration == '30 Days (RM9)') {
      var dur = Jiffy()..add(duration: Duration(days: 30));
      vpnEnd = dur.format('d/MM/yyyy').toString();
    } else if (duration == '60 Days (RM16)') {
      var dur = Jiffy()..add(duration: Duration(days: 60));
      vpnEnd = dur.format('d/MM/yyyy').toString();
    } else if (duration == '15 Days (RM7)') {
      var dur = Jiffy()..add(duration: Duration(days: 15));
      vpnEnd = dur.format('d/MM/yyyy').toString();
    } else if (duration == '30 Days (RM12)') {
      var dur = Jiffy()..add(duration: Duration(days: 30));
      vpnEnd = dur.format('d/MM/yyyy').toString();
    } else if (duration == '60 Days (RM18)') {
      var dur = Jiffy()..add(duration: Duration(days: 60));
      vpnEnd = dur.format('d/MM/yyyy').toString();
    }

    //take money from user :)
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot? snapshot = await transaction.get(refUser);

      if (!snapshot.exists) {
        status = 'User not exist';
      }

      int moneyCount = snapshot.get('Money') - vpnPrice;

      transaction.update(
        refUser,
        {
          'Money': moneyCount,
        },
      );
    });

    //update to user data

    Map<String, dynamic> updateData = {
      'VPN end': vpnEnd,
      'isPending': false,
      'isPay': true,
      'Status': 'Active',
      'Remarks': remarks,
      'timeStamp': FieldValue.serverTimestamp(),
    };

    await refVPN.update(updateData);

    //delete from order list
    await _firestore.collection('Order').doc(vpnUID).delete();

    status = 'operation-completed';

    return status;
  }
}
