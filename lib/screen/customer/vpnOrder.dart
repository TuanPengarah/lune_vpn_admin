import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lune_vpn_admin/ui/no_data.dart';
import 'package:string_validator/string_validator.dart';

Widget vpnOrderPage(String? uid) {
  return Container(
    child: StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Agent')
          .doc(uid)
          .collection('Order')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height / 1.5,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: Colors.deepOrangeAccent,
              ),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return NoData(
            reason: 'This user does not order any VPN',
          );
        }
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: snapshot.data!.docs.map((doc) {
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
                      _information(
                        Icons.timer,
                        doc['Duration'],
                      ),
                      _status == 'Active'
                          ? _information(Icons.date_range,
                              '${DateFormat('d/MM/yyyy').format(doc['timeStamp']!.toDate()).toString()} - ${doc['VPN end']}')
                          : Container(),
                      _information(Icons.location_on, doc['serverLocation']),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _harga == 0 ? 'Free Trial' : 'RM $_harga',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
