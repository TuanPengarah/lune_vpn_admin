import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lune_vpn_admin/dialog/logout_dialog.dart';
import 'package:lune_vpn_admin/main.dart';
import 'package:lune_vpn_admin/provider/auth_services.dart';
import 'package:lune_vpn_admin/provider/current_user.dart';
import 'package:lune_vpn_admin/screen/home/ui/card_admin.dart';
import 'package:lune_vpn_admin/screen/home/ui/header.dart';
import 'package:lune_vpn_admin/screen/news/news_page.dart';
import 'package:lune_vpn_admin/snackbar/error_snackbar.dart';
import 'package:lune_vpn_admin/snackbar/success_snackbar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  int _newsLength = 0;
  int _customerLength = 0;
  int _ordersLength = 0;
  int _problemsLength = 0;
  int _filesLength = 0;
  String? _myName = 'Loading';
  bool _doneCheck = false;

  Future<void> getLengthDocs() async {
    await _db
        .collection('News')
        .get()
        .then((snapshot) => _newsLength = snapshot.docs.length);
    await _db
        .collection('Agent')
        .get()
        .then((snapshot) => _customerLength = snapshot.docs.length);
    await _db
        .collection('Order')
        .get()
        .then((snapshot) => _ordersLength = snapshot.docs.length);
    await _db
        .collection('userReport')
        .get()
        .then((snapshot) => _problemsLength = snapshot.docs.length);
    await FirebaseStorage.instance.ref('ovpn/').listAll().then((value) {
      setState(() {
        _filesLength = value.items.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool? _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: StreamBuilder(
        stream: _db.collection('UserAdmin').doc(_user!.uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.data!.exists) {
            context.read<AuthenticationServices>().signOut().then(
                  (value) => showErrorSnackBar('Wait..you are not admin!!', 2),
                );
          } else {
            _myName = snapshot.data!['Name'];
            if (_doneCheck == false) {
              _doneCheck = true;
              print('Welcome back admin!');
              getLengthDocs();
            }
          }
          return RefreshIndicator(
            backgroundColor: Theme.of(context).primaryColor,
            color: Colors.white,
            onRefresh: () async {
              await getLengthDocs().then(
                (value) => showSuccessSnackBar('Refresh completed', 2),
              );
            },
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    headerHome(context, _myName.toString()),
                    SizedBox(height: 40),
                    Text(
                      'Let\'s managed your VPN services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 200,
                      child: Divider(
                        thickness: 1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 15,
                      children: [
                        cardAdmin(
                          title: 'News',
                          total: _newsLength,
                          icon: Icons.feed,
                          color: Colors.brown,
                          onPressed: () async {
                            messengerKey.currentState!.removeCurrentSnackBar();
                            await Future.delayed(Duration(milliseconds: 250));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewsPage()));
                          },
                        ),
                        cardAdmin(
                          title: 'Customer',
                          total: _customerLength,
                          icon: Icons.person,
                          color: Colors.orangeAccent,
                          onPressed: () {
                            messengerKey.currentState!.removeCurrentSnackBar();
                          },
                        ),
                        cardAdmin(
                          title: 'Orders',
                          total: _ordersLength,
                          icon: Icons.ballot,
                          color: Colors.lightGreen,
                          onPressed: () {
                            messengerKey.currentState!.removeCurrentSnackBar();
                          },
                        ),
                        cardAdmin(
                          title: 'Report',
                          total: _problemsLength,
                          icon: Icons.bug_report,
                          color: Colors.red,
                          onPressed: () {
                            messengerKey.currentState!.removeCurrentSnackBar();
                          },
                        ),
                        cardAdmin(
                          title: 'VPN Files',
                          total: _filesLength,
                          icon: Icons.upload_file,
                          color: Colors.blueGrey,
                          onPressed: () {
                            messengerKey.currentState!.removeCurrentSnackBar();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.settings,
        spaceBetweenChildren: 10,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        activeIcon: Icons.settings,
        children: [
          SpeedDialChild(
            label: 'Dark Mode',
            child: Icon(
              Icons.dark_mode,
              color: _isDarkMode ? Colors.amberAccent : Colors.black,
            ),
            onTap: () {
              _isDarkMode
                  ? AdaptiveTheme.of(context).setLight()
                  : AdaptiveTheme.of(context).setDark();
            },
          ),
          SpeedDialChild(
            label: 'Log Out',
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
            onTap: () {
              messengerKey.currentState!.removeCurrentSnackBar();
              showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
