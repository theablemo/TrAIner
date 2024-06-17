import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:trainerproject/models/user_info.dart';

class UserInfoPreferences {
  static const String userKey = 'userInfo';

  Future<void> saveUserInfo(UserInfo userInfo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userKey, jsonEncode(userInfo.toMap()));
  }

  Future<UserInfo?> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoString = prefs.getString(userKey);
    if (userInfoString == null) {
      return null;
    }
    Map<String, dynamic> userMap = jsonDecode(userInfoString);
    return UserInfo.fromMap(userMap);
  }

  Future<void> clearUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(userKey);
  }
}
