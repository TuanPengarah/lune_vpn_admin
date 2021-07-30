import 'package:flutter/cupertino.dart';

class CurrentUser extends ChangeNotifier {
  String? name = 'Unknown';
  int currentNews = 0;
  int currentCustomer = 0;
  int currentOrder = 0;
  int currentReport = 0;
  int currentVPN = 0;

  newsSet(int value) {
    currentNews = value;
    notifyListeners();
  }

  customerSet(int value) {
    currentCustomer = value;
    notifyListeners();
  }

  orderSet(int value) {
    currentOrder = value;
    notifyListeners();
  }

  reportSet(int value) {
    currentReport = value;
    notifyListeners();
  }

  fileSet(int value) {
    currentVPN = value;
    notifyListeners();
  }

  setName(String? newName) {
    name = newName;
    notifyListeners();
  }
}
