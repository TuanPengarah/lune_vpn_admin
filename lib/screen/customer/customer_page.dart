import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
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
                text: 'Customers',
              ),
              Tab(
                text: 'Agents',
              ),
              Tab(
                text: 'Admins',
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            Center(
              child: Container(
                child: Text('Customer'),
              ),
            ),
            Center(
              child: Container(
                child: Text('Agent'),
              ),
            ),
            Center(
              child: Container(
                child: Text('Admin'),
              ),
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          heroTag: 'Customer',
          label: Text(
            'Add member',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepOrangeAccent,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          icon: Icons.person_add,
          onPress: () {},
        ),
      ),
    );
  }
}
