import 'dart:async';
import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:narraited_mobile_app/provider/chapterSection/chapters.dart';
import 'package:narraited_mobile_app/provider/chatSection/chatmessages.dart';
import 'package:narraited_mobile_app/screens/chat_screen/audio_player.dart';
import 'package:narraited_mobile_app/screens/chat_screen/audio_recorder.dart';
import 'package:narraited_mobile_app/utilities/icons/chat_screen_icons.dart';
import 'package:narraited_mobile_app/utilities/styles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../provider/chapterSection/chapter_history.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {Key? key,})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StreamSubscription<bool> subscription;

  // function to return back to previous screen
  bool returnBack() {
    Provider.of<ChapterHistory>(context, listen: false).reset();
    Provider.of<ChaptersList>(context, listen: false).updateChapterStatus();
    Navigator.pop(context);
    return true;
  }

  // toggle visibility when keyboard is pressed
  final FocusNode _focusNode = FocusNode();
  bool _isVisibleText = false;
  void _toggleVisibility() {
    setState(() {
      _isVisibleText = !_isVisibleText;
    });
    _focusNode.requestFocus();
    _focusNode.unfocus();
  }

  // toggle visibilty when keyboard is hidden
  void toggleVisibility() {
    setState(() {
      _isVisibleText = !_isVisibleText;
    });
  }

  //  temporary file

  late File tempFile;

  void initDirectory() async {
    Directory tempDir = await getTemporaryDirectory();
    tempFile = File(tempDir.path);
  }

  void deleteTempFile() async {
    try {
      await tempFile.delete(recursive: true);
    } catch (e) {
      debugPrint('Error deleting temporary file: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatMessages>(context, listen: false)
                                .reset();
    });
    initDirectory();
    subscription = KeyboardVisibilityController().onChange.listen((event) {
      final message = event ? "opened" : "close";
      if (message == "close") {
        toggleVisibility();
      }
    });
  }

  @override
  void dispose() {
    deleteTempFile();
    _focusNode.dispose();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return returnBack();
        },
        // ignore: prefer_const_constructors
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text("DemoApp",style: TextStyle(color: Colors.blueAccent),),
              bottom: PreferredSize(preferredSize: const Size.fromHeight(150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                   TextFormField(
                    maxLines: 1,
                    cursorColor: Colors.blueAccent,

                    decoration: const InputDecoration(
                      hintText: "Enter text or url context you would like to discuss about",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.none, color: Colors.blueAccent
                        )
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.none, color: Colors.blueAccent
                        )
                      )
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: (){
                        //Set context with text Api call
                      },style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent
                      ), child: const Text("Set context with text")),
                      ElevatedButton(onPressed: (){
                        //Set context with url Api call
                      },style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent
                      ), child: const Text("Set context with url"))
                    ],
                  )
                ],
              ),)
            ),
            body: chatSection(),
            bottomNavigationBar: Consumer<ChatMessages>(
                // ignore: non_constant_identifier_names, avoid_types_as_parameter_names
                builder: (context, ChatMessages, child) {
              return Visibility(
                  visible: ChatMessages.chatBottomNavigationStatus,
                  replacement: Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    width: double.infinity,
                    color: Colors.white,
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: const Color(0xff1C75B6),
                        size: 25,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xff1C75B6),
                            shape: BoxShape.circle,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    // ignore: prefer_const_constructors
                                    return AudioRecorder(
                                      tempFile: tempFile,
                                    );
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15),
                                shape: const CircleBorder(),
                                elevation: 0.0,
                                backgroundColor: Colors.transparent),
                            child: const Icon(
                              ChatScreenIcons.mic,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: _toggleVisibility,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            elevation: 0.0,
                            padding: const EdgeInsets.all(20),
                            backgroundColor: Colors.white,
                          ),
                          child: const Icon(
                            ChatScreenIcons.keyboard,
                            color: Color(0xff1C75B6),
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ));
            })));
  }

  // message input controller
  final messageInsert = TextEditingController();

  // function to get chat from gpt
  void getQuestion(String message) async {
    if (!mounted) {
      return;
    }
    Provider.of<ChatMessages>(context, listen: false)
        .getQuestion(message);
  }

  // ScrollController listScrollController = ScrollController();
  // chat section function
  Widget chatSection() {
    // ignore: sized_box_for_whitespace
    return Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: <Widget>[
            Flexible(
                flex: 20,
                child: Consumer<ChatMessages>(
                  // ignore: non_constant_identifier_names, avoid_types_as_parameter_names
                  builder: (context, ChatMessages, child) {
                    return ListView.builder(
                        reverse: true,
                        itemCount: ChatMessages.messsages.length,
                        itemBuilder: (context, index) {
                          if (ChatMessages.messsages[index].type == "text") {
                            return chat(
                                ChatMessages.messsages[index].message!,
                                ChatMessages.messsages[index].origin!,
                                ChatMessages.messsages[index].time!);
                          } else {
                            return AudioPlayer(
                              key: Key('$index'),
                              filepath:
                                  ChatMessages.messsages[index].audioMessage!,
                              audioText:
                                  ChatMessages.messsages[index].audioText!,
                              time: ChatMessages.messsages[index].time!,
                            );
                          }
                        });
                  },
                )),
            Visibility(
              visible: _isVisibleText,
              child: ListTile(
                title: TextFormField(
                  maxLines: null,
                  controller: messageInsert,
                  decoration: const InputDecoration(
                    hintText: "Start  a conversation",
                    hintStyle: TextStyle(color: Colors.black26),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  focusNode: _focusNode,
                  cursorColor: const Color(0xff1C75B6),
                  autofocus: true,
                ),
                trailing: IconButton(
                    icon: const Icon(
                      Icons.send_outlined,
                      size: 30.0,
                      color: Color(0xff1C75B6),
                    ),
                    onPressed: () {
                      if (messageInsert.text.isNotEmpty) {
                        Provider.of<ChatMessages>(context, listen: false)
                            .insertTextMessage(1, messageInsert.text);
                        getQuestion(messageInsert.text);
                        messageInsert.clear();
                      }
                      if (!_focusNode.hasPrimaryFocus) {
                        _focusNode.unfocus();
                      }
                    }),
              ),
            )
          ],
        ));
  }

  Widget chat(String message, int data, String time) {
    return Column(
      crossAxisAlignment:
          data == 1 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            data == 0
                // ignore: sized_box_for_whitespace
                ? Container(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                        'assets/images/chatscreen_chatBot.svg'),
                  )
                : Text(
                    time,
                    style: const TextStyle(fontSize: 10),
                  ),
            const SizedBox(
              width: 5,
            ),
            data == 0
                ? Text(
                    time,
                    style: const TextStyle(fontSize: 10),
                  )
                : const SizedBox(
                    width: 15,
                  ),
          ],
        ),
        Bubble(
            margin: const BubbleEdges.all(7),
            // ignore: prefer_const_constructors
            radius: Radius.circular(15.0),
            color:
                data == 0 ? const Color(0xffF4F4F4) : const Color(0xff1C75B6),
            elevation: 0.0,
            child: Padding(
              // ignore: prefer_const_constructors
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // ignore: prefer_const_constructors
                  Flexible(
                      child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      message,
                      // ignore: prefer_const_constructors
                      style: data == 0
                          ? Styles.ChatbubbleStyleBot
                          : Styles.ChatbubbleStyleUser,
                    ),
                  ))
                ],
              ),
            )),
      ],
    );
  }
}
