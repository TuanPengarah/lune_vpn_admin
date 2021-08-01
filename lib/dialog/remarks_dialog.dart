import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

Future<String?> showRemarksDialog(
  BuildContext context,
  String hint,
  String title,
) async {
  final _textController = TextEditingController();

  String? text;

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: Text(
      'Enter your remarks to $title',
    ),
    content: TextField(
      autofocus: true,
      controller: _textController,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: '$hint',
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
          text = null;
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
        onPressed: () {
          text = _textController.text;
          Navigator.of(context).pop();
        },
      ),
    ],
  );
  await DialogBackground(
    blur: 6,
    dismissable: false,
    dialog: alert,
  ).show(context);
  return text;
}
