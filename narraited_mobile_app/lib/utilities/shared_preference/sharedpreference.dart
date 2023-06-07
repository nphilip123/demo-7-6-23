import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static const String userKey = 'userid';
  static const String userName = 'username';
  static const String userEmail = 'useremail';
  static const String userToken = 'usertoken';

  // getter for the userid value
  static Future<String> getUserKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userKey) ?? "null";
  }

  // setter for the userid value
  static Future<void> setUserKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, value);
  }

  // getter for the username value
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userName) ?? "null";
  }

  // setter for the username value
  static Future<void> setUserName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userName, value);
  }

  // getter for the useremail value
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmail) ?? "null";
  }

  // setter for the useremail value
  static Future<void> setUserEmail(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmail, value);
  }
  // getter for the usertoken value
  static Future<String> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userToken) ?? "null";
  }

  // setter for the usertoken value
  static Future<void> setUserToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userToken, value);
  }
}
