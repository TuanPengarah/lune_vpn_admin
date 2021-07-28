import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class LoginWrapper extends StatelessWidget {
  const LoginWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool? _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.dark_mode,
              color: _isDarkMode ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              _isDarkMode
                  ? AdaptiveTheme.of(context).setLight()
                  : AdaptiveTheme.of(context).setDark();
            },
          )
        ],
      ),
    );
  }
}
