class ChapterHistoryModel {
  String? id;
  String? question;
  String? answer;
  bool isplaying;

  ChapterHistoryModel({
    this.id,
    this.question,
    this.answer,
    required this.isplaying
  });

  factory ChapterHistoryModel.fromJson(Map<String, dynamic> json) =>
      ChapterHistoryModel(
        id: json['_id'] ?? '',
        question: json['question'] ?? '',
        answer: json['answer'] ?? '',
        isplaying: false,
      );
}
