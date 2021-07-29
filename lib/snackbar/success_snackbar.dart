import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/main.dart';

showSuccessSnackBar(String title, int duration) {
  messengerKey.currentState!.showSnackBar(
    SnackBar(
      content: Text(title),
      backgroundColor: Colors.green,
      duration: Duration(seconds: duration),
    ),
  );
}
