import 'package:flutter/cupertino.dart';

class CurrentUser extends ChangeNotifier {
  String? name = 'Unknown';

  setName(String? newName) {
    name = newName;
    notifyListeners();
  }
}
