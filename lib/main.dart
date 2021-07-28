import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/services/theme_data.dart';
import 'login/wrapper_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(
    themeMode: savedThemeMode,
  ));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? themeMode;

  MyApp({this.themeMode});
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: MyThemes.lightTheme,
        dark: MyThemes.darkTheme,
        initial: themeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Lune VPN Admin',
            theme: theme,
            darkTheme: darkTheme,
            home: LoginWrapper(),
          );
        });
  }
}
