import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:lune_vpn_admin/dialog/global_dialog.dart';
import 'package:lune_vpn_admin/provider/current_user.dart';
import 'package:lune_vpn_admin/screen/report/bottom_bar.dart';
import 'package:lune_vpn_admin/ui/loading_progess.dart';
import 'package:lune_vpn_admin/ui/no_data.dart';
import 'package:ndialog/ndialog.dart';
import 'package:string_validator/string_validator.dart';
import 'package:provider/provider.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int? _isAvailable = context.watch<CurrentUser>().currentReport;
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text('User Report'),
            backgroundColor: Colors.red,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('userReport')
                      .orderBy('timeStamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.2,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: Colors.brown,
                          ),
                        ),
                      );
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      context.read<CurrentUser>().reportSet(0);
                      return NoData(
                          icon: Icons.assignment_turned_in,
                          reason: 'Congratulations! You got empty report list');
                    }
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        context
                            .read<CurrentUser>()
                            .reportSet(snapshot.data!.docs.length);
                        String? _status = doc['Status'];
                        int? _harga = doc['Harga'];
                        IconData? _statusIcon() {
                          IconData? icon;
                          if (equals('Active', _status)) {
                            icon = Icons.done;
                          } else if (equals('Expired', _status)) {
                            icon = Icons.error;
                          } else if (equals('Pending', _status)) {
                            icon = Icons.pending;
                          } else if (equals('Canceled', _status)) {
                            icon = Icons.cancel_presentation;
                          }
                          return icon;
                        }

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () async {
                              String? phone = '0';
                              final customProgress = CustomProgressDialog(
                                  context,
                                  blur: 6,
                                  dismissable: false);
                              customProgress.show();
                              await FirebaseFirestore.instance
                                  .collection('Agent')
                                  .doc(doc['userUID'])
                                  .get()
                                  .then((value) =>
                                      phone = value.data()!['Phone']);
                              customProgress.dismiss();
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => bottomBar(
                                  doc['Agent'],
                                  phone,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.person),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          doc['Agent'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  _information(
                                    Icons.vpn_key,
                                    doc['Username'],
                                  ),
                                  _information(
                                    Icons.timer,
                                    doc['Duration'],
                                  ),
                                  _status == 'Active'
                                      ? _information(Icons.date_range,
                                          '${DateFormat('d/MM/yyyy').format(doc['timeStamp']!.toDate()).toString()} - ${doc['VPN end']}')
                                      : Container(),
                                  _information(
                                      Icons.location_on, doc['serverLocation']),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                _harga == 0
                                                    ? 'Free Trial'
                                                    : 'RM $_harga',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    _statusIcon(),
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    doc['Status'],
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 120),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        visible: _isAvailable <= 0 ? false : true,
        heroTag: 'Report',
        label: Text(
          'Clear all report',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        icon: Icons.delete,
        onPress: () {
          showGlobalDialog(context, () async {
            final customProgress =
                CustomProgressDialog(context, blur: 6, dismissable: false);
            customProgress.setLoadingWidget(
                showLoadingProgress(context, 'Deleting all report...'));

            customProgress.show();
            var collection =
                FirebaseFirestore.instance.collection('userReport');
            var snapshots = await collection.get();
            for (var doc in snapshots.docs) {
              await doc.reference.delete();
            }
            Navigator.of(context).pop();
            customProgress.dismiss();
          });
        },
      ),
    );
  }
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
