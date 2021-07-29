import 'package:flutter/material.dart';

SizedBox textBarLogin({
  required BuildContext context,
  required TextInputType inputType,
  required IconData icon,
  required bool isPassword,
  required TextInputAction inputAction,
  required TextEditingController textController,
  required bool isMobile,
  Function(String)? onEnter,
  String? label,
  String? hint,
  String? error,
}) {
  return SizedBox(
    width: isMobile == true ? MediaQuery.of(context).size.width : 450,
    child: TextField(
      controller: textController,
      obscureText: isPassword,
      keyboardType: inputType,
      textInputAction: inputAction,
      onSubmitted: onEnter,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label ?? '',
        hintText: hint ?? '',
        errorText: error,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
      ),
    ),
  );
}
