import 'package:flutter/material.dart';

class CombinedListen extends ChangeNotifier {
  final List<ChangeNotifier> listeners;

  CombinedListen(this.listeners) {
    for (final listener in listeners) {
      listener.addListener(notifyListeners);
    }
  }

  @override
  void dispose() {
    for (final listener in listeners) {
      listener.removeListener(notifyListeners);
    }
    super.dispose();
  }
}