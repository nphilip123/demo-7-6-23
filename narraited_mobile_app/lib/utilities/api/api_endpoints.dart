class ApiEndPoints {
  // static const String baseUrl = "http://20.66.79.74:8080/";
  static const String baseUrl = "https://api.narraited.com/";
  // static const String baseUrl = "http://10.10.1.182:8080/";

  static GoogleSigninEndPoints googleSigninEndPoints = GoogleSigninEndPoints();
  static ChatSectionEndPoints chatSectionEndPoints = ChatSectionEndPoints();
  static HomeSectionEndPoints homeSectionEndPoints = HomeSectionEndPoints();
  static ChapterSectionEndPoints chapterSectionEndPoints =
      ChapterSectionEndPoints();
  static BiographySectionEndPoints biographySectionEndPoints =
      BiographySectionEndPoints();
}

class GoogleSigninEndPoints {
  final String signIn = 'signin';
  final String logout = 'logout';
  final String setUserChapters = 'category';
}

class ChatSectionEndPoints {
  final String chatInput = 'input-text';
}

class BiographySectionEndPoints {
  final String generateFullBiography = 'biography';
}

class HomeSectionEndPoints {
  final String userProfile = 'profile';
  final String userChapters = 'list/chapters';
  final String userChapterAdd = 'category/add';
  final String userChapterRemove = 'category/remove';
  final String userChapterRename = 'category/rename';
  final String userChapterRearrange = 'chapter/rearrange';
  final String userChapterCompletedStatus = 'chapter/complete';
}

class ChapterSectionEndPoints {
  final String chapter = 'chapter';
  final String textConversion = 'text-speech';
  final String conversationDelete = 'conversation/remove';
  final String conversationEdit = 'conversation/edit';
}
