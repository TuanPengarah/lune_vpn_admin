import 'package:flutter/material.dart';

Widget cardAdmin({
  required String title,
  required int total,
  required IconData icon,
  required Color color,
  required Function() onPressed,
}) {
  return Material(
    color: Colors.transparent,
    child: Ink(
      height: 190,
      width: 150,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: title,
                  child: Container(
                    height: 3,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    letterSpacing: 1.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 5),
                Icon(
                  icon,
                  color: Colors.grey,
                  size: 40,
                ),
                SizedBox(height: 5),
                Text(
                  total <= 0 ? '-' : '$total',
                  style: TextStyle(
                    letterSpacing: 1.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.w900,
                    fontSize: 35,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
