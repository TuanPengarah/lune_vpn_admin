import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/dialog/remarks_dialog.dart';
import 'package:lune_vpn_admin/provider/current_user.dart';
import 'package:lune_vpn_admin/provider/firestore_services.dart';
import 'package:lune_vpn_admin/snackbar/error_snackbar.dart';
import 'package:lune_vpn_admin/snackbar/success_snackbar.dart';
import 'package:lune_vpn_admin/ui/loading_progess.dart';
import 'package:lune_vpn_admin/ui/no_data.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatelessWidget {
  ///CANCELING ORDER
  void _cancelOrder({
    required BuildContext context,
    required String value,
    required String userUID,
    required String vpnUID,
  }) async {
    final customProgress =
        CustomProgressDialog(context, blur: 6, dismissable: false);
    customProgress.setLoadingWidget(
      showLoadingProgress(
        context,
        'Cancelling Order...',
      ),
    );
    customProgress.show();

    await context
        .read<FirestoreService>()
        .canceledOrder(
          vpnUID: vpnUID,
          userUID: userUID,
          reason: value,
        )
        .then((s) async {
      if (s == 'operation-completed') {
        FirebaseFirestore.instance
            .collection('Agent')
            .doc(userUID)
            .get()
            .then((snapshot) async {
          List<dynamic> info = snapshot.data()!['tokens'];
          HttpsCallable call = FirebaseFunctions.instance.httpsCallable(
              'sendToAgent',
              options: HttpsCallableOptions(timeout: Duration(seconds: 5)));
          final results = await call(<String, dynamic>{
            'tokens': info,
          });
          print(results);
        });
        customProgress.dismiss();
        showSuccessSnackBar('Order has been canceled', 2);
      } else {
        customProgress.dismiss();
        showErrorSnackBar('Aw Snap, an error occured: $s', 3);
      }
    });
  }

  ///ACCEPT ORDER
  void _acceptOrder({
    required BuildContext context,
    required String value,
    required String? userUID,
    required String? vpnUID,
    required String duration,
    required int harga,
  }) async {
    final customProgress =
        CustomProgressDialog(context, blur: 6, dismissable: false);
    customProgress.setLoadingWidget(
      showLoadingProgress(
        context,
        'Performing calculation...',
      ),
    );
    customProgress.show();

    //check balanced
    await FirebaseFirestore.instance
        .collection('Agent')
        .doc(userUID)
        .get()
        .then((snap) async {
      int myMoney = snap.data()!['Money'];
      if (myMoney >= harga) {
        print('duit cukup');
        await context
            .read<FirestoreService>()
            .acceptOrder(
              userUID: userUID,
              vpnUID: vpnUID,
              remarks: value,
              duration: duration,
              vpnPrice: harga,
            )
            .then((s) async {
          if (s == 'operation-completed') {
            FirebaseFirestore.instance
                .collection('Agent')
                .doc(userUID)
                .get()
                .then((snapshot) async {
              List<dynamic> info = snapshot.data()!['tokens'];
              HttpsCallable call = FirebaseFunctions.instance.httpsCallable(
                  'sendToAgent',
                  options: HttpsCallableOptions(timeout: Duration(seconds: 5)));
              final results = await call(<String, dynamic>{
                'tokens': info,
              });
              print(results);
            });
            customProgress.dismiss();
            showSuccessSnackBar('Your order has been completed', 2);
          } else {
            customProgress.dismiss();
            showErrorSnackBar('Aw Snap, an error occured', 3);
          }
        });
      } else {
        customProgress.dismiss();
        showErrorSnackBar(
            'Not enough money!, please topup money for this user to accept this order',
            5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Order List',
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Order')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: Colors.lightGreen,
                ),
              ),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            context.read<CurrentUser>().orderSet(0);
            return NoData(
              reason: 'No order found!',
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: snapshot.data!.docs.map((doc) {
                context
                    .read<CurrentUser>()
                    .orderSet(snapshot.data!.docs.length);
                int? _harga = doc['Harga'];
                return Card(
                  child: ExpandablePanel(
                    header: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.vpn_key),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  doc['Username'],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          _information(Icons.person, doc['Agent']),
                          _information(Icons.timer, doc['Duration']),
                          _information(
                              Icons.location_on, doc['serverLocation']),
                          _information(Icons.payments,
                              _harga == 0 ? 'Free Trial' : 'RM $_harga'),
                        ],
                      ),
                    ),
                    collapsed: Container(),
                    expanded: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.red,
                              ),
                            ),
                            onPressed: () {
                              showRemarksDialog(context, 'Duit tak cukup',
                                      'to cancel this order')
                                  .then((v) {
                                if (v != null) {
                                  _cancelOrder(
                                      context: context,
                                      value: v,
                                      userUID: doc['userUID'],
                                      vpnUID: doc['vpnUID']);
                                }
                              });
                            },
                            icon: Icon(Icons.cancel),
                            label: Text('Cancel Order'),
                          ),
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.lightGreen,
                              ),
                            ),
                            onPressed: () {
                              showRemarksDialog(context, 'Password vpn: 123456',
                                      'to accept this order')
                                  .then((v) {
                                if (v != null) {
                                  _acceptOrder(
                                    context: context,
                                    value: v,
                                    userUID: doc['userUID'],
                                    vpnUID: doc['vpnUID'],
                                    duration: doc['Duration'],
                                    harga: doc['Harga'],
                                  );
                                }
                              });
                            },
                            icon: Icon(Icons.done),
                            label: Text('Accept Order'),
                          ),
                        ],
                      ),
                    ),
                    theme: ExpandableThemeData(
                      tapBodyToExpand: true,
                      tapBodyToCollapse: true,
                      tapHeaderToExpand: true,
                      iconColor: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _information(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 14,
          ),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
