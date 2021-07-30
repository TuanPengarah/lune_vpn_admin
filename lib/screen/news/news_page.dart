import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
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
                      return Column(
                        children: snapshot.data!.docs.map((doc) {
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
                                      doc['Tarikh'],
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
                                  children: [
                                    Text(doc['Content']),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {},
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
              ],
            ),
          )
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
          setState(() {});
        },
      ),
    );
  }
}
