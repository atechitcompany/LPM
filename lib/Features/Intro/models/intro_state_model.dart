import 'package:flutter/material.dart';

class IntroStateModel extends ChangeNotifier {
  int currentPage = 0;

  void updatePage(int index) {
    currentPage = index;
    notifyListeners();
  }
}
