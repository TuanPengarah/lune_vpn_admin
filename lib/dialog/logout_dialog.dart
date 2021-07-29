import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/provider/auth_services.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';

Future<bool?> showLogoutDialog(BuildContext context) async {
  bool? isLogout = false;
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: Text('Sign Out'),
    content: Text('Are you sure want to sign out?'),
    actions: [
      TextButton(
        child: Text(
          'Cancel',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        onPressed: () {
          isLogout = false;
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.red,
          ),
        ),
        onPressed: () async {
          print('signing out...');
          isLogout = true;
          await context
              .read<AuthenticationServices>()
              .signOut()
              .then((value) => Navigator.of(context).pop());
        },
      ),
    ],
  );
  await DialogBackground(
    blur: 6,
    dialog: alert,
  ).show(context);
  return isLogout;
}
