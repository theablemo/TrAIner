import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider with ChangeNotifier {
  late String _apiKey;
  static const String chatKey = 'apikey';

  String get apiKey => _apiKey;

  void loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(chatKey);
    if (key != null && key.isNotEmpty) {
      _apiKey = key;
    } else {
      _apiKey = "AIzaSyC5RZa__UsJvGfv6tckyrEpnVdvRgccyTI";
    }
    notifyListeners();
  }

  void setApiKey(String key) async {
    _apiKey = key;

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(chatKey, apiKey);

    notifyListeners();
  }
}
