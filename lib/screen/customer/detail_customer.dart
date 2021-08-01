import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/dialog/global_dialog.dart';
import 'package:lune_vpn_admin/dialog/topup_dialog.dart';
import 'package:lune_vpn_admin/provider/firestore_services.dart';
import 'package:lune_vpn_admin/screen/customer/vpnOrder.dart';
import 'package:lune_vpn_admin/snackbar/error_snackbar.dart';
import 'package:lune_vpn_admin/snackbar/success_snackbar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class CustomerDetails extends StatefulWidget {
  final String? name;
  final String? phone;
  final String? email;
  final String? uid;
  final int? money;
  final bool? isAgent;

  const CustomerDetails({
    Key? key,
    this.name,
    this.phone,
    this.email,
    this.uid,
    this.money,
    this.isAgent,
  }) : super(key: key);

  @override
  _CustomerDetailsState createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  int? _currentMoney;

  void _handleClick(String value) {
    switch (value) {
      case 'Remove this user':
        showGlobalDialog(context, () {
          context.read<FirestoreService>().deleteUser(widget.uid).then((s) {
            if (s == 'operation-completed') {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              showSuccessSnackBar('User has been deleted', 2);
            } else {
              showErrorSnackBar('Error deleting this user: $s', 3);
            }
          });
        });
        break;
    }
  }

  void _launchEmail() async {
    final url =
        "mailto:${widget.email}?subject=Pemberitahuan daripada Lune VPN&body=Salam "
        "${widget.name},";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showErrorSnackBar('Cannot launch url $url', 2);
    }
  }

  void _launchCaller() async {
    final url = "tel:${widget.phone}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showErrorSnackBar('Cannot launch url $url', 2);
    }
  }

  @override
  void initState() {
    super.initState();

    _currentMoney = widget.money;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.isAgent == true ? 'Agent Details' : 'Customer Details'),
          backgroundColor: Colors.deepOrangeAccent,
          actions: [
            PopupMenuButton(
              onSelected: _handleClick,
              itemBuilder: (BuildContext context) {
                return {'Remove this user'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
          bottom: TabBar(
            physics: BouncingScrollPhysics(),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'VPN Request'),
            ],
          ),
        ),
        body: TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            detailsPage(context),
            vpnOrderPage(widget.uid),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView detailsPage(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Name'),
                  subtitle: Text('${widget.name}'),
                  onTap: () {
                    Share.share('${widget.name}');
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone Number'),
                  subtitle: Text('${widget.phone}'),
                  onTap: () {
                    _launchCaller();
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text('${widget.email}'),
                  onTap: () {
                    _launchEmail();
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('E-Wallet'),
                  subtitle: Text('RM$_currentMoney\nClick here to topup'),
                  isThreeLine: true,
                  onTap: () {
                    showTopupDialog(context, widget.uid).then(
                      (value) {
                        if (value != null) {
                          setState(() {
                            _currentMoney = value;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.fingerprint),
                  title: Text('User UID'),
                  subtitle: Text('${widget.uid}'),
                  onTap: () {
                    Share.share('${widget.uid}');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
