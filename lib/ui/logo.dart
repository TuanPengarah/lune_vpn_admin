import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool? _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Image.asset(
          'assets/images/vpn.png',
          scale: 3,
        ),
        SizedBox(height: 5),
        Text.rich(
          TextSpan(
              text: 'Lune ',
              style: GoogleFonts.bebasNeue(
                fontSize: 29,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.blue[400] : Colors.black,
              ),
              children: [
                TextSpan(
                  text: 'VPN',
                  style: GoogleFonts.bebasNeue(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ]),
        ),
      ],
    );
  }
}
