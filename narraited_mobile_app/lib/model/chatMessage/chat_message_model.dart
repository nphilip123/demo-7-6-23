import 'dart:io';

class ChatMessageModel {
  String? type;
  int? origin;
  String? message;
  String? time;
  File? audioMessage;
  String? audioText;

  ChatMessageModel({
    this.type,
    this.origin,
    this.message,
    this.time,
    this.audioMessage,
    this.audioText,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        type: json['_id'] ?? '',
        origin: json['categoryName'] ?? '',
        message: json['messsage'] ?? '',
        time: json['time'] ?? '',
        audioMessage: json['audioMessage'] ?? '',
        audioText: json['audioText'] ?? '',
      );
}
