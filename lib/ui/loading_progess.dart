import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget showLoadingProgress(BuildContext context, String title) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
