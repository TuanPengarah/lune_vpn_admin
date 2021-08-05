import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lune_vpn_admin/provider/current_user.dart';
import 'package:lune_vpn_admin/screen/customer/add_customer.dart';
import 'package:lune_vpn_admin/screen/customer/detail_customer.dart';
import 'package:lune_vpn_admin/ui/no_data.dart';
import 'package:provider/provider.dart';

class CustomerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Customer and members'),
          backgroundColor: Colors.deepOrangeAccent,
          bottom: TabBar(
            physics: BouncingScrollPhysics(),
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: 'All',
              ),
              Tab(
                text: 'Customers',
              ),
              Tab(
                text: 'Agents',
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            buildPage(false, true),
            buildPage(false, false),
            buildPage(true, false),
          ],
        ),
        floatingActionButton: SpeedDial(
          heroTag: 'Customer',
          label: Text(
            'Add User',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepOrangeAccent,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          icon: Icons.person_add,
          onPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => CustomerAdd(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildPage(bool isAgent, bool isAll) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              StreamBuilder(
                  stream: isAll == false
                      ? FirebaseFirestore.instance
                          .collection('Agent')
                          .orderBy('Name', descending: false)
                          .where('isAgent', isEqualTo: isAgent)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('Agent')
                          .orderBy('Name', descending: false)
                          .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      if (isAll == true) {
                        context.read<CurrentUser>().customerSet(0);
                      }
                      return NoData(
                        icon: Icons.person_off,
                        reason: 'No user found, You can create new user by '
                            'pressing on + icon!',
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: snapshot.data!.docs.map(
                          (doc) {
                            context
                                .read<CurrentUser>()
                                .customerSet(snapshot.data!.docs.length);
                            return Card(  
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text(
                                  doc['Name'],
                                ),
                                subtitle: Text(doc['Phone']),
                                trailing: Text(
                                  'RM${doc['Money']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) => CustomerDetails(
                                        name: doc['Name'],
                                        phone: doc['Phone'],
                                        email: doc['Email'],
                                        uid: doc.id,
                                        money: doc['Money'],
                                        isAgent: doc['isAgent'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    );
                  }),
              SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}
