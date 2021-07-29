import 'package:cloud_firestore/cloud_firestore.dart';
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
                          return Text(doc['Title']);
                        }).toList(),
                      );
                    }),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: SpeedDial(
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
