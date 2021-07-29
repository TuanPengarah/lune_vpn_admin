import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/main.dart';

showErrorSnackBar(String title, int duration) {
  messengerKey.currentState!.showSnackBar(
    SnackBar(
      content: Text(title),
      backgroundColor: Colors.red,
      duration: Duration(seconds: duration),
    ),
  );
}
