import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

Future<void> showGlobalDialog(
    BuildContext context, Function() onPressed) async {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: Text('Proceed with caution!'),
    content: Text('Are you sure want to perform this action?'),
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
        onPressed: onPressed,
      ),
    ],
  );
  await DialogBackground(
    blur: 6,
    dialog: alert,
  ).show(context);
}
