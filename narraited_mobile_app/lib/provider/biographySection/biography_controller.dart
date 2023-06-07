import 'dart:convert';
import 'dart:io';


import '../../utilities/api/api_endpoints.dart';
import '../../utilities/shared_preference/sharedpreference.dart';
import 'package:http/http.dart' as http;

class BiographyController {
  static Future<dynamic> generateFullBiography() async {
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.biographySectionEndPoints.generateFullBiography}');
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
        final data = jsonDecode(response.body);
        return data;
      } else {
        return "Error";
      }
    } on SocketException{
      return ('Error');
    } catch (e) {
      return ('Error');
    }
  }
}
