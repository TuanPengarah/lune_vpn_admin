import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/snackbar/error_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

Widget bottomBar(String? name, String? phone) => Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 5),
                Text(
                  '$name',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SelectableText(
                  '$phone',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _contain(
                      Icons.phone,
                      'Call',
                      () async {
                        final url = "tel:$phone";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          showErrorSnackBar('Cannot launch url $url', 2);
                        }
                      },
                    ),
                    _contain(Icons.chat, 'WhatsApp', () async {
                      final url = 'https://wa.me/6$phone';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        showErrorSnackBar('Cannot launch url $url', 2);
                      }
                    }),
                    _contain(
                      Icons.sms,
                      'Message',
                      () async {
                        final url = "sms:$phone";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          showErrorSnackBar('Cannot launch url $url', 2);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        )
      ],
    );

Widget _contain(IconData? icon, String? title, Function()? onPressed) {
  return InkWell(
    onTap: onPressed,
    child: Ink(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 50),
            SizedBox(height: 10),
            Text('$title'),
          ],
        ),
      ),
    ),
  );
}
