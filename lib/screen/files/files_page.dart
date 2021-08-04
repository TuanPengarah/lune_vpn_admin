import 'dart:io';
import 'dart:typed_data';
import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/dialog/global_dialog.dart';
import 'package:lune_vpn_admin/dialog/upload_sheet.dart';
import 'package:lune_vpn_admin/dialog/upload_sheet_web.dart';
import 'package:lune_vpn_admin/provider/current_user.dart';
import 'package:lune_vpn_admin/provider/storage_hosting.dart';
import 'package:lune_vpn_admin/snackbar/success_snackbar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ndialog/ndialog.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({Key? key}) : super(key: key);

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late Future<List<FirebaseFile>> futureFiles;

  File? _file;

  @override
  void initState() {
    super.initState();
    futureFiles = StorageAPI.listAll('ovpn/');
  }

  void deletedFiles(
    BuildContext context,
    int index,
    List<FirebaseFile> files,
    String? url,
    String? name,
  ) {
    final customProgress = CustomProgressDialog(context, blur: 6);
    showGlobalDialog(context, () {
      customProgress.show();
      FirebaseStorage.instance.refFromURL(url!).delete().then((value) {
        setState(() {
          files.removeAt(index);
        });
        Navigator.of(context).pop();
        context.read<CurrentUser>().fileSet(files.length);
        customProgress.dismiss();
        showSuccessSnackBar('File $name has been deleted', 2);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VPN Files'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () async {
              setState(() {
                futureFiles = StorageAPI.listAll('ovpn/');
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<FirebaseFile>>(
          future: futureFiles,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case (ConnectionState.waiting):
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Fetching data from server...')
                    ],
                  ),
                );
              default:
                if (snapshot.data!.isEmpty) {
                  context.read<CurrentUser>().fileSet(0);
                  return Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_late,
                            color: Colors.grey,
                            size: 100,
                          ),
                          SizedBox(height: 20),
                          Text('Uh Oh! Vpn files not found!'),
                          TextButton(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(allowMultiple: false);

                              if (result != null) {
                                PlatformFile content = result.files.first;
                                Uint8List? fileBytes = result.files.first.bytes;
                                //web version
                                if (kIsWeb) {
                                  String fileName = result.files.first.name;
                                  await showUploadSheetWeb(
                                          context,
                                          'ovpn/$fileName',
                                          content.name,
                                          fileBytes)
                                      .then((b) {
                                    print(b);
                                    if (b == true) {
                                      setState(() {
                                        futureFiles =
                                            StorageAPI.listAll('ovpn/');
                                      });
                                    }
                                  });
                                  // await FirebaseStorage.instance
                                  //     .ref('ovpn/$fileName')
                                  //     .putData(fileBytes!);
                                } else {
                                  //android
                                  final path = result.files.single.path!;
                                  _file = File(path);
                                  final getFile = basename(_file!.path);
                                  final filePath = 'ovpn/$getFile';
                                  await showUploadSheet(context, filePath,
                                          content.name, _file!, fileBytes)
                                      .then((b) {
                                    print(b);
                                    if (b == true) {
                                      setState(() {
                                        futureFiles =
                                            StorageAPI.listAll('ovpn/');
                                      });
                                    }
                                  });
                                }
                              }
                            },
                            child: Text('Add VPN files'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  final files = snapshot.data!;

                  return Column(
                    children: [
                      ListTile(
                        tileColor: Colors.blueGrey,
                        leading: Icon(
                          Icons.text_snippet,
                          color: Colors.white,
                        ),
                        title: Text(
                          '${files.length} files available',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          physics: BouncingScrollPhysics(),
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            context.read<CurrentUser>().fileSet(files.length);
                            return Card(
                              child: ExpandablePanel(
                                header: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.vpn_key),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${file.name}',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  tooltip: 'Delete',
                                                  onPressed: () {
                                                    deletedFiles(
                                                      context,
                                                      index,
                                                      files,
                                                      file.url,
                                                      file.name,
                                                    );
                                                  },
                                                  icon: Icon(Icons.delete)),
                                              IconButton(
                                                tooltip: 'Share',
                                                onPressed: () async {
                                                  kIsWeb == false
                                                      ? await StorageAPI
                                                          .downloadFile(
                                                              file.ref)
                                                      : Share.share(
                                                          '${file.url}');
                                                },
                                                icon: Icon(Icons.share),
                                              ),
                                              IconButton(
                                                tooltip: 'Download',
                                                onPressed: () async {
                                                  StorageAPI.launchWeb(
                                                      file.url);
                                                },
                                                icon: Icon(Icons.download),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                theme: ExpandableThemeData(
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
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(allowMultiple: false);

                          if (result != null) {
                            PlatformFile content = result.files.first;
                            Uint8List? fileBytes = result.files.first.bytes;
                            //web version
                            if (kIsWeb) {
                              String fileName = result.files.first.name;
                              await showUploadSheetWeb(context,
                                      'ovpn/$fileName', content.name, fileBytes)
                                  .then((b) {
                                print(b);
                                if (b == true) {
                                  setState(() {
                                    futureFiles = StorageAPI.listAll('ovpn/');
                                  });
                                }
                              });
                              // await FirebaseStorage.instance
                              //     .ref('ovpn/$fileName')
                              //     .putData(fileBytes!);
                            } else {
                              //android
                              final path = result.files.single.path!;
                              _file = File(path);
                              final getFile = basename(_file!.path);
                              final filePath = 'ovpn/$getFile';
                              await showUploadSheet(context, filePath,
                                      content.name, _file!, fileBytes)
                                  .then((b) {
                                print(b);
                                if (b == true) {
                                  setState(() {
                                    futureFiles = StorageAPI.listAll('ovpn/');
                                  });
                                }
                              });
                            }
                          }
                        },
                        child: Ink(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          color: Colors.blueGrey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.note_add, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Add VPN Files',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
            }
          }),
    );
  }
}
