import 'dart:typed_data';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lune_vpn_admin/provider/storage_hosting.dart';
import 'package:lune_vpn_admin/snackbar/success_snackbar.dart';
import 'package:ndialog/ndialog.dart';

Future<bool> showUploadSheetWeb(
  BuildContext context,
  String filePath,
  String fileName,
  Uint8List? bytes,
) async {
  bool isUpload = false;
  await showFlexibleBottomSheet(
    minHeight: 0,
    initHeight: 0.6,
    maxHeight: 0.7,
    context: context,
    builder: (
      BuildContext context,
      ScrollController scrollController,
      double bottomSheetOffset,
    ) {
      UploadTask? task;
      final customProgress =
          CustomProgressDialog(context, blur: 6, dismissable: false);
      return Material(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  'Do you want to upload this file?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Icon(
                  Icons.insert_drive_file,
                  color: Colors.grey,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  fileName,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                SizedBox(
                  width: 280,
                  height: 45,
                  child: ElevatedButton(
                    child: Text('Upload this file'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blueGrey,
                      ),
                    ),
                    onPressed: () async {
                      customProgress.setLoadingWidget(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text('Uploading...'),
                          ],
                        ),
                      );
                      task = StorageAPI.uploadBytes(filePath, bytes);
                      if (task == null) return;
                      customProgress.show();
                      final snapshot = await task!.whenComplete(() {});
                      final urlDownload = await snapshot.ref.getDownloadURL();
                      print('upload completed: $urlDownload');
                      isUpload = true;
                      customProgress.dismiss();
                      Navigator.of(context).pop();
                      showSuccessSnackBar('Upload Completed!', 2);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
  return isUpload;
}
