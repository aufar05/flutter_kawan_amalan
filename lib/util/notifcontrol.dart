import 'package:flutter/material.dart';

class NotifData extends ChangeNotifier {
  bool _notificationEnabled = false;

  bool get notificationEnabled => _notificationEnabled;

  void toggleNotification() {
    _notificationEnabled = !_notificationEnabled;
    notifyListeners();
  }
}
