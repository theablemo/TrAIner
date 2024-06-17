import 'package:flutter/foundation.dart';
import '../../models/user_info.dart';
import '../preferences/user_preferences.dart';

class UserInfoProvider with ChangeNotifier {
  UserInfo? _userInfo;
  final UserInfoPreferences _userPreferences = UserInfoPreferences();

  UserInfo? get userInfo => _userInfo;

  Future<void> loadUserInfo() async {
    _userInfo = await _userPreferences.getUserInfo();
    notifyListeners();
  }

  Future<void> saveUserInfo(UserInfo userInfo) async {
    _userInfo = userInfo;
    await _userPreferences.saveUserInfo(userInfo);
    notifyListeners();
  }

  Future<void> clearUserInfo() async {
    _userInfo = null;
    await _userPreferences.clearUserInfo();
    notifyListeners();
  }
}
