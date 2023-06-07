import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/chatMessage/chat_message_model.dart';
import '../../utilities/api/api_endpoints.dart';
import '../../utilities/shared_preference/sharedpreference.dart';
import 'package:http/http.dart' as http;

import '../chapterSection/chapter_history.dart';

class ChatMessages with ChangeNotifier {
  List<ChatMessageModel> messsages = [];
  bool chatBottomNavigationStatus = true;

  void insertTextMessage(int user, String message) {
    String time = DateFormat("Hm").format(DateTime.now());
    ChatMessageModel chapter = ChatMessageModel(
      type: "text",
      message: message,
      origin: user,
      time: time,
    );
    messsages.insert(0,chapter);
    notifyListeners();
  }

  void setchatBottomNavigationStatus(bool value) {
    chatBottomNavigationStatus = value;
    notifyListeners();
  }

  void setFirstmessage(String categoryId) async {
    chatBottomNavigationStatus = false;
    notifyListeners();
    var history = await ChapterHistory.fetchChat(categoryId);
    if (history == "null" || history == "Error") return;
    for (final set in history['Conversation']) {
      if (set['question'] != null && set['answer'] == null) {
        String time = DateFormat("Hm").format(DateTime.now());
        // ignore: use_build_context_synchronously
        ChatMessageModel chapter = ChatMessageModel(
          type: "text",
          message: set['question'],
          origin: 0,
          time: time,
        );
        messsages.insert(0,chapter);
        chatBottomNavigationStatus = true;
        notifyListeners();
      }
    }
  }

  void insertAudioText(File message, String path,) {
    // debugPrint("${message.path},$path");
    chatBottomNavigationStatus = false;
    notifyListeners();
    sttConversion(message, path).then((value) {
      String time = DateFormat("Hm").format(DateTime.now());
      if (value != "Error") {
        ChatMessageModel chapter = ChatMessageModel(
          type: "audio",
          origin: 1,
          audioMessage: message,
          audioText: value['audio'],
          time: time,
        );
        messsages.insert(0,chapter);
        ChatMessageModel chapter1 = ChatMessageModel(
          type: "text",
          origin: 0,
          message: value['response'],
          time: time,
        );
        messsages.insert(0,chapter1);
      } else {
        ChatMessageModel chapter = ChatMessageModel(
          type: "text",
          origin: 1,
          message:"Error",
          time: time,
        );
        messsages.insert(0,chapter);
      }
      chatBottomNavigationStatus = true;
      notifyListeners();
    });
  }

  void reset() async {
    messsages = [];
    notifyListeners();
  }

  void getQuestion(String message) async {
    setchatBottomNavigationStatus(false);
    dynamic data = await fetchChat(message);
    if (data['response'] != null) {
      insertTextMessage(0, data['response']);
    } else {
      insertTextMessage(0, "Connection Error");
    }
    setchatBottomNavigationStatus(true);
  }

  static Future<dynamic> fetchChat(String message) async {
    Map<String, String> queryParams = {
      'id': "demo",
    };
    String queryString = Uri(queryParameters: queryParams).query;
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.chatSectionEndPoints.chatInput}?$queryString');
    String token = await SharedPreferenceUtil.getUserToken();
    final body = jsonEncode({'text': message});
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
        return "Error Connecting Try again later";
      }
    } on SocketException catch (e) {
      return ('Sorry Session timed out: $e');
    } catch (e) {
      return ('Sorry an error occurred: $e');
    }
  }

  static Future<dynamic> sttConversion(
      File audio, String path) async {
    return FFmpegKit.execute('-i ${audio.path} -f wav $path')
        .then((session) async {
      // ignore: unrelated_type_equality_checks
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        // debugPrint('Conversion successful!');
      } else {
        // debugPrint('Conversion failed with exit code $returnCode');
      }
    }).then((value) async {
      List<int> bytes = File(path).readAsBytesSync();

      Map<String, String> queryParams = {
        'contentType': 'audio',
      };
      String queryString = Uri(queryParameters: queryParams).query;
      final url = Uri.parse(
          '${ApiEndPoints.baseUrl}${ApiEndPoints.chatSectionEndPoints.chatInput}/?$queryString');
      String token = await SharedPreferenceUtil.getUserToken();
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'audio/mpeg',
            'Authorization': 'Bearer $token',
          },
          body: bytes,
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['request'] != null &&
              data['response'] != null &&
              data['audio'] != null) {
            return data;
          } else {
            return "Error";
          }
        } else {
          return "Error";
        }
      } on SocketException {
        return "Error";
      } catch (e) {
        return "Error";
      }
    });
  }
}
