import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/main.dart';

showNotifSnackBar(String title, int duration) {
  messengerKey.currentState!.showSnackBar(
    SnackBar(
      content: Text(title),
      duration: Duration(seconds: duration),
    ),
  );
}
