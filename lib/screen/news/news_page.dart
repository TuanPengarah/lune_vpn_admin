import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:lune_vpn_admin/dialog/global_dialog.dart';
import 'package:lune_vpn_admin/provider/current_user.dart';
import 'package:lune_vpn_admin/provider/firestore_services.dart';
import 'package:lune_vpn_admin/screen/news/news_add.dart';
import 'package:lune_vpn_admin/ui/no_data.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _dateFormat = DateFormat('d/MM/yyyy hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text('News And Announcement'),
            backgroundColor: Colors.brown,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('News')
                        .orderBy('Tarikh', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
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
                        context.read<CurrentUser>().newsSet(0);
                        return NoData(
                          icon: Icons.feed,
                          reason: 'You can create news by pressing + icon',
                        );
                      }
                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          context
                              .read<CurrentUser>()
                              .newsSet(snapshot.data!.docs.length);
                          String convertTimeStamp() {
                            try {
                              Timestamp _timeStamp = doc['Tarikh'];
                              var _convert = _timeStamp.toDate();
                              return _dateFormat.format(_convert).toString();
                            } catch (e) {
                              print(e);
                              return e.toString();
                            }
                          }

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ExpandablePanel(
                              header: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc['Title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      convertTimeStamp().toString(),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                              collapsed: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13.0, vertical: 5),
                                child: Text(
                                  doc['Subtitle'],
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              expanded: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(doc['Content']),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          showGlobalDialog(context, () async {
                                            await context
                                                .read<FirestoreService>()
                                                .deleteNews(doc.id);
                                            Navigator.of(context).pop();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              theme: ExpandableThemeData(
                                inkWellBorderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                tapBodyToExpand: true,
                                tapBodyToCollapse: true,
                                tapHeaderToExpand: true,
                                iconColor: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        heroTag: 'News',
        label: Text(
          'Add news',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        icon: Icons.add,
        onPress: () {
          setState(() {
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => NewsAdd()));
          });
        },
      ),
    );
  }
}
