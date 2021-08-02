import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/provider/auth_services.dart';
import 'package:lune_vpn_admin/provider/current_user.dart';
import 'package:lune_vpn_admin/provider/firestore_services.dart';
import 'package:lune_vpn_admin/screen/home/home.dart';
import 'package:lune_vpn_admin/services/theme_data.dart';
import 'package:provider/provider.dart';
import 'screen/login/login_screen.dart';

// flutter run -d web-server --web-port 8080 --web-hostname 192.168.1.17

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await Firebase.initializeApp();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(
    themeMode: savedThemeMode,
  ));
}

final messengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? themeMode;

  MyApp({this.themeMode});
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: MyThemes.lightTheme(context),
        dark: MyThemes.darkTheme(context),
        initial: themeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) {
          return MultiProvider(
            providers: [
              Provider<AuthenticationServices>(
                create: (context) =>
                    AuthenticationServices(FirebaseAuth.instance),
              ),
              Provider<CurrentUser>(create: (context) => CurrentUser()),
              Provider<FirestoreService>(
                create: (context) =>
                    FirestoreService(FirebaseFirestore.instance),
              ),
            ],
            builder: (context, snapshot) {
              return MaterialApp(
                scaffoldMessengerKey: messengerKey,
                debugShowCheckedModeBanner: false,
                title: 'Lune VPN Admin',
                theme: theme,
                darkTheme: darkTheme,
                home: LoginWrapper(),
              );
            },
          );
        });
  }
}

class LoginWrapper extends StatefulWidget {
  @override
  _LoginWrapperState createState() => _LoginWrapperState();
}

class _LoginWrapperState extends State<LoginWrapper> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, user) {
          if (user.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        });
  }
}
