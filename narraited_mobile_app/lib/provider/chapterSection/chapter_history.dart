import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:narraited_mobile_app/provider/chapterSection/chapters.dart';

import '../../model/chapterHistoryModel/chapter_history_model.dart';
import '../../utilities/api/api_endpoints.dart';
import '../../utilities/shared_preference/sharedpreference.dart';
import 'package:http/http.dart' as http;

class ChapterHistory with ChangeNotifier {
  List<ChapterHistoryModel> historyList = [];
  bool historyLoadStatus = false;
  bool loaderStatus = true;
  bool global = false;
  int id = 0;
  void setHistory(String categoryId) async {
    var history = await fetchChat(categoryId);
    if (history == "null" || history == "Error") {
      historyLoadStatus = false;
      loaderStatus = false;
      notifyListeners();
      return;
    }
    int id = 0;
    for (var set in history['Conversation']) {
      if (set['question'] != null && set['answer'] != null) {
        ChapterHistoryModel chapter = ChapterHistoryModel.fromJson(set);
        historyList.add(chapter);
        id++;
      }
    }
    if (id > 0) {
      historyLoadStatus = true;
    }
    loaderStatus = false;
    notifyListeners();
  }

  void reset() {
    historyList = [];
    historyLoadStatus = false;
    loaderStatus = true;
    global = false;
    notifyListeners();
  }

  void setPlaying(String id) {
    for (var card in historyList) {
      card.isplaying = false;
      if (card.id == id) {
        global = true;
        card.isplaying = !card.isplaying;
      }
    }
  }

  void setNotPlaying() {
    global = false;
    for (var card in historyList) {
      card.isplaying = false;
    }
  }

  void deleteConv(String id, String categoryId, ChaptersList chaptersList,
      int index) async {
    historyList.removeWhere((item) => item.id == id);
    notifyListeners();
    if (historyList.isEmpty) {
      chaptersList.setChapterStatusTodo(index);
      historyLoadStatus = false;
      loaderStatus = false;
      notifyListeners();
    }
    deleteConversation(id, categoryId);
  }

  void editConv(String id, String categoryId, String editedResponse) async {
    ChapterHistoryModel? targetObject =
        historyList.firstWhere((obj) => obj.id == id);
    targetObject.answer = editedResponse;
    notifyListeners();
    await editConversation(id, categoryId, editedResponse);
  }

  static Future<dynamic> fetchChat(String categoryId) async {
    Map<String, String> queryParams = {
      'id': categoryId,
    };
    String queryString = Uri(queryParameters: queryParams).query;
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.chapterSectionEndPoints.chapter}?$queryString');
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
        if (data['Conversation'] == "Empty conversation") {
          return "null";
        } else {
          return data;
        }
      } else {
        return "Error";
      }
    } on SocketException{
      return ("Error");
    } catch (e) {
      return ("Error");
    }
  }

  static Future<dynamic> deleteConversation(
      String conversationId, String categoryId) async {
    Map<String, String> queryParams = {
      'id': categoryId,
      'questionId': conversationId,
    };
    String queryString = Uri(queryParameters: queryParams).query;
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.chapterSectionEndPoints.conversationDelete}?$queryString');
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
    } on SocketException{
      return ("Error");
    } catch (e) {
      return ("Error");
    }
  }

  static Future<dynamic> editConversation(
      String conversationId, String categoryId, String editedResponse) async {
    Map<String, String> queryParams = {
      'id': categoryId,
      'chatId': conversationId,
    };
    String queryString = Uri(queryParameters: queryParams).query;
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.chapterSectionEndPoints.conversationEdit}?$queryString');
    String token = await SharedPreferenceUtil.getUserToken();
    try {
      final response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'updatedChat': editedResponse,
          }));
      if (response.statusCode == 200) {
        return "success";
      } else {
        return "Error";
      }
    } on SocketException{
      return ("Error");
    } catch (e) {
      return ("Error");
    }
  }

  static Future<dynamic> ttsConversion(String text) async {
    final url = Uri.parse(ApiEndPoints.baseUrl +
        ApiEndPoints.chapterSectionEndPoints.textConversion);
    String token = await SharedPreferenceUtil.getUserToken();
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'text': text,
          }));
      if (response.statusCode == 200) {
        final data = response.bodyBytes;
        return data;
      } else {
        return "Error";
      }
    } on SocketException{
      return ("Error");
    } catch (e) {
      return ("Error");
    }
  }
}
