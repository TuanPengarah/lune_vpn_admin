import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lune_vpn_admin/dialog/logout_dialog.dart';
import 'package:lune_vpn_admin/main.dart';
import 'package:lune_vpn_admin/provider/auth_services.dart';
import 'package:lune_vpn_admin/provider/current_user.dart';
import 'package:lune_vpn_admin/screen/customer/customer_page.dart';
import 'package:lune_vpn_admin/screen/files/files_page.dart';
import 'package:lune_vpn_admin/screen/home/ui/card_admin.dart';
import 'package:lune_vpn_admin/screen/home/ui/header.dart';
import 'package:lune_vpn_admin/screen/news/news_page.dart';
import 'package:lune_vpn_admin/screen/order/order_page.dart';
import 'package:lune_vpn_admin/screen/report/report_page.dart';
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

  String? _myName = 'Loading';
  bool _doneCheck = false;
  String? _devices = 'Flutter';

  Future<void> _checkDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      _devices = '${webBrowserInfo.platform} | ${webBrowserInfo.product}';
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _devices = '${androidInfo.brand} | ${androidInfo.model}';
    }
  }

  Future<void> getLengthDocs() async {
    print('initiate refresh list');
    await _db.collection('News').get().then((snapshot) =>
        context.read<CurrentUser>().newsSet(snapshot.docs.length));
    await _db.collection('Agent').get().then((snapshot) =>
        context.read<CurrentUser>().customerSet(snapshot.docs.length));
    await _db.collection('Order').get().then((snapshot) =>
        context.read<CurrentUser>().orderSet(snapshot.docs.length));
    await _db.collection('userReport').get().then((snapshot) =>
        context.read<CurrentUser>().reportSet(snapshot.docs.length));
    await FirebaseStorage.instance.ref('ovpn/').listAll().then((value) {
      setState(() {
        context.read<CurrentUser>().fileSet(value.items.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool? _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    int _newsLength = context.watch<CurrentUser>().currentNews;
    int _customerLength = context.watch<CurrentUser>().currentCustomer;
    int _ordersLength = context.watch<CurrentUser>().currentOrder;
    int _problemsLength = context.watch<CurrentUser>().currentReport;
    int _filesLength = context.watch<CurrentUser>().currentVPN;
    return Scaffold(
      body: StreamBuilder(
        stream: _db.collection('userAdmin').doc(_user!.uid).snapshots(),
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
              _checkDevice();
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
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewsPage()));
                            setState(() {});
                          },
                        ),
                        cardAdmin(
                          title: 'Customer',
                          total: _customerLength,
                          icon: Icons.person,
                          color: Colors.deepOrangeAccent,
                          onPressed: () async {
                            messengerKey.currentState!.removeCurrentSnackBar();
                            await Future.delayed(Duration(milliseconds: 250));
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CustomerPage()));
                            setState(() {});
                          },
                        ),
                        cardAdmin(
                          title: 'Orders',
                          total: _ordersLength,
                          icon: Icons.ballot,
                          color: Colors.lightGreen,
                          onPressed: () async {
                            messengerKey.currentState!.removeCurrentSnackBar();
                            await Future.delayed(Duration(milliseconds: 250));
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderPage()));
                            setState(() {});
                          },
                        ),
                        cardAdmin(
                          title: 'VPN Files',
                          total: _filesLength,
                          icon: Icons.upload_file,
                          color: Colors.blueGrey,
                          onPressed: () async {
                            messengerKey.currentState!.removeCurrentSnackBar();
                            await Future.delayed(Duration(milliseconds: 250));
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilesPage(),
                              ),
                            );
                            setState(() {});
                          },
                        ),
                        cardAdmin(
                          title: 'Report',
                          total: _problemsLength,
                          icon: Icons.bug_report,
                          color: Colors.red,
                          onPressed: () async {
                            messengerKey.currentState!.removeCurrentSnackBar();
                            await Future.delayed(Duration(milliseconds: 250));
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportPage(),
                              ),
                            );
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Text(
                      'Lune VPN Admin 0.0.6\nRunning on $_devices',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
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
