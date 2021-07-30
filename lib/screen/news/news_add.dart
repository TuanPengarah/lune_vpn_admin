import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lune_vpn_admin/dialog/global_dialog.dart';
import 'package:lune_vpn_admin/provider/firestore_services.dart';
import 'package:lune_vpn_admin/snackbar/success_snackbar.dart';
import 'package:provider/provider.dart';

class NewsAdd extends StatefulWidget {
  const NewsAdd({Key? key}) : super(key: key);

  @override
  _NewsAddState createState() => _NewsAddState();
}

class _NewsAddState extends State<NewsAdd> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _contentController = TextEditingController();
  final _date = DateFormat('d/MM/yyyy hh:mm a').format(DateTime.now());
  String? _titleText = 'Title';
  String? _subtitleText = 'Subtitle';
  String? _contentText = 'Your content goes here...';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text('Add News'),
            backgroundColor: Colors.brown,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Your news should look like this..',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Card(
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
                                  _titleController.text.isEmpty
                                      ? 'Title'
                                      : '$_titleText',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '$_date',
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
                              _subtitleController.text.isEmpty
                                  ? 'Subtitle'
                                  : '$_subtitleText',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          expanded: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  _contentController.text.isEmpty
                                      ? 'Your content goes here...'
                                      : '$_contentText',
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
                            iconColor:
                                Theme.of(context).textTheme.bodyText1!.color,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Divider(),
                      SizedBox(height: 15),
                      TextField(
                        controller: _titleController,
                        onChanged: (text) {
                          setState(() {
                            _titleText = text;
                          });
                        },
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Enter your title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _subtitleController,
                        onChanged: (text) {
                          setState(() {
                            _subtitleText = text;
                          });
                        },
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Enter your subtitle',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _contentController,
                        onChanged: (text) {
                          setState(() {
                            _contentText = text;
                          });
                        },
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Enter your content here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await showGlobalDialog(context, () async {
                              await context.read<FirestoreService>().createNews(
                                  _titleText, _subtitleText, _contentText);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              showSuccessSnackBar('Creating news success', 2);
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.brown),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text('Create news'),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
