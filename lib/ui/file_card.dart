import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lune_vpn_admin/provider/storage_hosting.dart';

class FileInfo extends StatelessWidget {
  const FileInfo({
    Key? key,
    this.file,
  }) : super(key: key);

  final FirebaseFile? file;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpandablePanel(
        header: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.vpn_key),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${file!.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        collapsed: Container(),
        expanded: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Center(
                child: Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.delete),
                        label: Text('Delete'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                      ),
                    ),
                    kIsWeb
                        ? Container()
                        : SizedBox(
                            width: 120,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await StorageAPI.downloadFile(file!.ref);
                              },
                              icon: Icon(Icons.share),
                              label: Text('Share'),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blueGrey),
                              ),
                            ),
                          ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 130,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          StorageAPI.launchWeb(file!.url);
                        },
                        icon: Icon(Icons.download),
                        label: Text('Download'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blueGrey),
                        ),
                      ),
                    ),
                  ],
                ),
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
  }
}
