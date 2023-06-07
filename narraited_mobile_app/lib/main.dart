import 'package:flutter/material.dart';
import 'package:narraited_mobile_app/provider/chapterSection/chapter_history.dart';
import 'package:narraited_mobile_app/provider/chapterSection/chapters.dart';
import 'package:narraited_mobile_app/provider/chatSection/chatmessages.dart';
import 'package:narraited_mobile_app/provider/userAuthSection/user_auth_controller.dart';
import 'package:narraited_mobile_app/screens/splash_section/splash_section.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<ChaptersList>(
        create: (context) => ChaptersList(),
      ),
      ChangeNotifierProvider<ChapterHistory>(
        create: (context) => ChapterHistory(),
      ),
      ChangeNotifierProvider<ChatMessages>(
        create: (context) => ChatMessages(),
      ),
      ChangeNotifierProvider<UserAuthContoller>(
        create: (context) => UserAuthContoller(),
      )
    ], child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          secondary: Colors.blue
        ),
        // ignore: prefer_const_constructors
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 0.2,
        ),
      ),
      home: const SplashSection(),
    );
  }
}
