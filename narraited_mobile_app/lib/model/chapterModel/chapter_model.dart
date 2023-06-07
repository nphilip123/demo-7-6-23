class ChapterModel {
  String? chapterName;
  String? status;
  String? categoryId;
  String? chapterColor;

  ChapterModel({
    this.chapterName,
    this.status,
    this.categoryId,
    this.chapterColor
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      ChapterModel(
        chapterName: json['CategoryName'] ?? '',
        categoryId: json['CategoryID'] ?? '',
        status: json['Status'] ?? '',
        chapterColor: '0xFFFFA500',
      );
  Map<String, dynamic> toJson() {
    return {
      'CategoryName': chapterName,
      'CategoryID': categoryId,
      'Status': status,
    };
  }
}
