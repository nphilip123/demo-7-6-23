import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/chapterModel/chapter_model.dart';
import '../../utilities/api/api_endpoints.dart';
import '../../utilities/shared_preference/sharedpreference.dart';
import 'package:http/http.dart' as http;

import '../userAuthSection/user_auth_controller.dart';

class ChaptersList with ChangeNotifier {
  List<ChapterModel> chapterList = [];
  bool chapterLoadStatus = false;

  //  === to assign color to chapters loaded ============

  final List<String> colorCodes = [
    '0xFFFFA500',
    '0xFFFF8C00',
    '0xFFFF7F50',
    '0xFF1EA65D',
    '0xFFF4A460',
    '0xFFCD853F',
    '0xFFFFB6C1',
    '0xFFFFA07A',
    '0xFFDC143C',
    '0xFFD2B48C',
    '0xFFBC8F8F',
    '0xFFA79703',
    '0xFF6D59CB'
  ];
  static int _previousColor = -1;
  String getRandomColorCode() {
    final random = Random();
    int colorIndex = random.nextInt(colorCodes.length);
    while (colorIndex == _previousColor) {
      colorIndex = random.nextInt(colorCodes.length);
    }
    _previousColor = colorIndex;
    return colorCodes[colorIndex];
  }

//  ==================================================

  void deleteChapter(int index, String categoryId) async {
    var response = await removeUserChapters(categoryId);
    if (response == "success") {
      chapterList.removeAt(index);
      notifyListeners();
    } else {
      debugPrint("chapter removal failed");
    }
  }

  void loadChapters() async {
    final chapterStatus = await UserAuthContoller.setUserChapters();
    if (chapterStatus == "sucessfull") {
      var chapterlist = await fetchUserChapters();
      if (chapterlist != "Error") {
        int i = 0;
        for (var chapter in chapterlist['Category']) {
          ChapterModel chapterMain = ChapterModel.fromJson(chapter);
          chapterMain.chapterColor = getRandomColorCode();
          chapterList.insert(i, chapterMain);
          i++;
        }
        chapterLoadStatus = true;
        notifyListeners();
      }
    }
  }

  void insertnewChapter(int index, String cardName, String categoryId) {
    bool status = false;
    for (var card in chapterList) {
      if (card.chapterName?.toLowerCase() == cardName.toLowerCase()) {
        status = true;
      }
    }
    if (status != true) {
      ChapterModel chapter = ChapterModel(
          chapterName: cardName, categoryId: categoryId, status: "TO DO", chapterColor: getRandomColorCode());
      chapterList.insert(index, chapter);
      notifyListeners();
    }
  }

  void renameChapter(
      int index, String cardName, String status, String categoryId, String chapterColor) async {
    String response = await renameUserChapters(cardName, categoryId);
    if (response == "success") {
      chapterList.removeAt(index);
      ChapterModel chapter = ChapterModel(
          chapterName: cardName, categoryId: categoryId, status: status, chapterColor: chapterColor);
      chapterList.insert(index, chapter);
      notifyListeners();
    }
  }

  void updateReorder() {
    notifyListeners();
  }

  void rearrange() async {
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.homeSectionEndPoints.userChapterRearrange}');
    String token = await SharedPreferenceUtil.getUserToken();
    final jsonData = chapterList.map((chapter) => chapter.toJson()).toList();
    final body = jsonEncode({'order': jsonData});
    try {
      await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
    } on SocketException catch (e) {
      debugPrint("Session timed out: $e");
    } catch (e) {
      debugPrint("an error occurred: $e");
    }
  }

  void updateChapterStatus() async {
    chapterLoadStatus = false;
    notifyListeners();
    reset();
    var chapterlist = await fetchUserChapters();
    if (chapterlist != "Error") {
      int i = 0;
      for (final category in chapterlist['Category']) {
        ChapterModel chapterMain = ChapterModel.fromJson(category);
        chapterMain.chapterColor = getRandomColorCode();
        chapterList.insert(i, chapterMain);
        i++;
      }
      chapterLoadStatus = true;
      notifyListeners();
    }
  }

  void setChapterStatusComplete(String chapterId) async {
    var response = await setChaptersCompleted(chapterId);
    if (response != "Error") {
      for (var chapter in chapterList) {
        if (chapter.categoryId == chapterId) {
          chapter.status = "COMPLETED";
          notifyListeners();
        }
      }
    }
  }

  void setChapterStatusTodo(int index) {
    chapterList[index].status = "TO DO";
    notifyListeners();
  }

  void reset() {
    chapterList = [];
    notifyListeners();
  }

  static Future<dynamic> removeUserChapters(String chapterId) async {
    Map<String, String> queryParams = {
      'id': chapterId,
    };
    String queryString = Uri(queryParameters: queryParams).query;
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.homeSectionEndPoints.userChapterRemove}?$queryString');
    String token = await SharedPreferenceUtil.getUserToken();
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return "success";
      } else {
        return "Error";
      }
    } on SocketException {
      return ('Error');
    } catch (e) {
      return ('Error');
    }
  }

  static Future<dynamic> fetchUserChapters() async {
    final url = Uri.parse(
        ApiEndPoints.baseUrl + ApiEndPoints.homeSectionEndPoints.userChapters);
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

  static Future<dynamic> addUserChapters(String message) async {
    final url = Uri.parse(ApiEndPoints.baseUrl +
        ApiEndPoints.homeSectionEndPoints.userChapterAdd);
    String token = await SharedPreferenceUtil.getUserToken();
    final body = jsonEncode({'categoryName': message});
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return "Error";
      }
    } on SocketException {
      return ('Error');
    } catch (e) {
      return ('Error');
    }
  }

  static Future<dynamic> renameUserChapters(
      String chapterName, String categoryId) async {
    Map<String, String> queryParams = {
      'id': categoryId,
    };
    String queryString = Uri(queryParameters: queryParams).query;
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.homeSectionEndPoints.userChapterRename}?$queryString');
    String token = await SharedPreferenceUtil.getUserToken();
    final body = jsonEncode({'name': chapterName});
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        return ("success");
      } else {
        return "Error";
      }
    } on SocketException{
      return ('Error');
    } catch (e) {
      return ('Error');
    }
  }

  static Future<dynamic> setChaptersCompleted(String chapterId) async {
    Map<String, String> queryParams = {
      'id': chapterId,
    };
    String queryString = Uri(queryParameters: queryParams).query;
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.homeSectionEndPoints.userChapterCompletedStatus}?$queryString');
    String token = await SharedPreferenceUtil.getUserToken();
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return "success";
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
