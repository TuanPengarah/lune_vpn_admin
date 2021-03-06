import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/provider/firestore_services.dart';
import 'package:lune_vpn_admin/snackbar/error_snackbar.dart';
import 'package:lune_vpn_admin/snackbar/success_snackbar.dart';
import 'package:lune_vpn_admin/ui/loading_progess.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';

Future<int?> showTopupDialog(BuildContext context, String? uid) async {
  final _topupController = TextEditingController();

  int? newMoney;

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: Text('Enter topup amount'),
    content: TextField(
      autofocus: true,
      controller: _topupController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '0.00',
      ),
    ),
    actions: [
      TextButton(
        child: Text(
          'Cancel',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.red,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text(
          'Continue',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).primaryColor,
          ),
        ),
        onPressed: () async {
          final customProgress =
              CustomProgressDialog(context, blur: 6, dismissable: false);
          customProgress.setLoadingWidget(
            showLoadingProgress(
              context,
              'Recharging user E-Wallet...',
            ),
          );
          customProgress.show();

          try {
            await context
                .read<FirestoreService>()
                .userTopup(int.parse(_topupController.text), uid)
                .then((value) async {
              FirebaseFirestore.instance
                  .collection('Agent')
                  .doc(uid)
                  .get()
                  .then((snapshot) async {
                List<dynamic> info = snapshot.data()!['tokens'];
                HttpsCallable call = FirebaseFunctions.instance.httpsCallable(
                    'topupNotif',
                    options:
                        HttpsCallableOptions(timeout: Duration(seconds: 5)));
                final results = await call(<String, dynamic>{
                  'tokens': info,
                  'value': _topupController.text,
                  'balanced': value
                });
                print(results);
              });
              customProgress.dismiss();
              newMoney = value;
              showSuccessSnackBar(
                  'User has been recharge RM${_topupController.text}! Current balanced RM$value',
                  3);
              Navigator.of(context).pop();
            });
          } catch (e) {
            customProgress.dismiss();
            Navigator.of(context).pop();
            showErrorSnackBar('An error occured: $e', 3);
          }
        },
      ),
    ],
  );
  await DialogBackground(
    blur: 6,
    dialog: alert,
  ).show(context);
  return newMoney;
}
