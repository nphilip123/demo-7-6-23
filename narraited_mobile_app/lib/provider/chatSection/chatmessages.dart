import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/chatMessage/chat_message_model.dart';
import '../../utilities/api/api_endpoints.dart';
// import '../../utilities/shared_preference/sharedpreference.dart';
import 'package:http/http.dart' as http;

class ChatMessages with ChangeNotifier {
  List<ChatMessageModel> messsages = [];
  bool chatBottomNavigationStatus = true;
  String activeToken = "Error";

  void insertTextMessage(int user, String message) {
    String time = DateFormat("Hm").format(DateTime.now());
    ChatMessageModel chapter = ChatMessageModel(
      type: "text",
      message: message,
      origin: user,
      time: time,
    );
    messsages.insert(0, chapter);
    notifyListeners();
  }

  void setchatBottomNavigationStatus(bool value) {
    chatBottomNavigationStatus = value;
    notifyListeners();
  }

  void setFirstmessage() async {
    chatBottomNavigationStatus = false;
    notifyListeners();
    String time = DateFormat("Hm").format(DateTime.now());
    // ignore: use_build_context_synchronously
    ChatMessageModel chapter = ChatMessageModel(
      type: "text",
      message: "Hello Start your session by setting the context above.",
      origin: 0,
      time: time,
    );
    messsages.insert(0, chapter);
    chatBottomNavigationStatus = true;
    notifyListeners();
  }

  void insertAudioText(
    File message,
    String path,
  ) {
    // debugPrint("${message.path},$path");
    chatBottomNavigationStatus = false;
    notifyListeners();
    sttConversion(message, path).then((value) async {
      String time = DateFormat("Hm").format(DateTime.now());
      if (value != "Error"){
        String botResponse = await fetchChat(value, activeToken);
        ChatMessageModel chapter = ChatMessageModel(
          type: "audio",
          origin: 1,
          audioMessage: message,
          audioText: value,
          time: time,
        );
        messsages.insert(0, chapter);
        ChatMessageModel chapter1 = ChatMessageModel(
          type: "text",
          origin: 0,
          message: botResponse,
          time: time,
        );
        messsages.insert(0, chapter1);
      } else {
        ChatMessageModel chapter = ChatMessageModel(
          type: "text",
          origin: 1,
          message: "Error",
          time: time,
        );
        messsages.insert(0, chapter);
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
    dynamic data = await fetchChat(message, activeToken);
    insertTextMessage(0, data);
    setchatBottomNavigationStatus(true);
  }

  void setcontext(String message) async {
    setchatBottomNavigationStatus(false);
    dynamic data = await setContext(message);
    activeToken = data;
    notifyListeners();
    setchatBottomNavigationStatus(true);
  }

  static Future<dynamic> setContext(String message) async {
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.chatSectionEndPoints.setContext}');
    final body = jsonEncode({'context': message});
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == "Context is saved") {
          return data['token'];
        } else {
          return 'Error';
        }
      } else {
        return "Error";
      }
    } on SocketException {
      return ('Error');
    } catch (e) {
      return ('Error');
    }
  }

  static Future<dynamic> fetchChat(String message, String activetoken) async {
    if (activetoken == "Error") {
      return "Error : context not set";
    }
    final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.chatSectionEndPoints.chatInput}');
    // String token = await SharedPreferenceUtil.getUserToken();
    final body = jsonEncode({'prompt': message, 'token': activetoken});
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('${data['message']}');
        return data['message'];
      } else {
        return "Error Connecting Try again later";
      }
    } on SocketException catch (e) {
      return ('Sorry Session timed out: $e');
    } catch (e) {
      return ('Sorry an error occurred: $e');
    }
  }

  static Future<dynamic> sttConversion(File audio, String path) async {
    return FFmpegKit.execute('-i ${audio.path} -f wav $path')
        .then((session) async {
      // ignore: unrelated_type_equality_checks
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('Conversion successful!');
      } else {
        debugPrint('Conversion failed with exit code $returnCode');
      }
    }).then((value) async {
      List<int> bytes = File(path).readAsBytesSync();
      final url = Uri.parse(
          '${ApiEndPoints.baseUrl1}${ApiEndPoints.chatSectionEndPoints.speechText}');
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'audio/mpeg',
          },
          body: bytes,
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['Text'] != null) {
            return data['Text'];
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
