import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:narraited_mobile_app/utilities/api/api_endpoints.dart';
import 'package:narraited_mobile_app/utilities/shared_preference/sharedpreference.dart';
import 'package:http/http.dart' as http;

class UserAuthContoller with ChangeNotifier {
  String userEmail = "Null";
  String userName = "Null";

  void resetUser() {
    userEmail = "Null";
    userName = "Null";
  }

  void setUser() async {
    userEmail = await SharedPreferenceUtil.getUserEmail();
    userName = await SharedPreferenceUtil.getUserName();
    notifyListeners();
  }

  static final _googleSignIn = GoogleSignIn();
  static Future<GoogleSignInAccount?> googleLogin() => _googleSignIn.signIn();
  static Future<GoogleSignInAccount?> googleLogout() =>
      _googleSignIn.disconnect();

  static Future<String?> loginUser(
      String name, String email, String userId) async {
    try {
      final url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.googleSigninEndPoints.signIn);
      final response = await http.post(
        url,
        body: {'email': email, 'username': name, 'userId': userId},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await SharedPreferenceUtil.setUserToken(data['accessToken']);
        return "success";
      } else {
        return jsonDecode(response.body)['Message'];
      }
      // ignore: unused_catch_clause
    } on SocketException catch (e) {
      return ('$e');
    } catch (e) {
      return ('$e');
    }
  }

  static Future<String?> signin() async {
    try {
      final user = await googleLogin();
      if (user != null) {
        String? usertoken =
            await loginUser(user.displayName as String, user.email, user.id);
        if (usertoken == "success") {
          await SharedPreferenceUtil.setUserKey(user.id);
          await SharedPreferenceUtil.setUserName(user.displayName as String);
          await SharedPreferenceUtil.setUserEmail(user.email);
          return "success";
        } else {
          await googleLogout();
          return usertoken;
        }
      } else {
        return "Sign in Canceled";
      }
      // ignore: unused_catch_clause
    } on SocketException catch (e) {
      return ('$e');
    } catch (e) {
      return ('$e');
    }
  }

  static Future<String> setUserChapters() async {
    final url = Uri.parse(ApiEndPoints.baseUrl +
        ApiEndPoints.googleSigninEndPoints.setUserChapters);
    String token = await SharedPreferenceUtil.getUserToken();
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return "sucessfull";
      } else {
        return "Error";
      }
    } on SocketException {
      return ("Error");
    } catch (e) {
      return ("Error");
    }
  }

  static Future logout() async {
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.googleSigninEndPoints.logout}');
    String token = await SharedPreferenceUtil.getUserToken();
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      debugPrint('Logout: ${data['message']}');
    } on SocketException catch (e) {
      debugPrint('Logout: An error occurred: $e');
    } catch (e) {
      debugPrint('Logout: An error occurred: $e');
    }
    googleLogout();
    await SharedPreferenceUtil.setUserKey("null");
    await SharedPreferenceUtil.setUserName("null");
    await SharedPreferenceUtil.setUserEmail("null");
    await SharedPreferenceUtil.setUserToken("null");
  }

  static Future<String> fetchUserDetails() async {
    final url = Uri.parse(
        ApiEndPoints.baseUrl + ApiEndPoints.homeSectionEndPoints.userProfile);
    String token = await SharedPreferenceUtil.getUserToken();
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        return "success";
      } else {
        return "Error";
      }
    } on SocketException  {
      return ('Error');
    } catch (e) {
      return ('Error');
    }
  }
}
