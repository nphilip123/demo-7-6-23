import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:narraited_mobile_app/provider/chapterSection/chapter_history.dart';
import 'package:narraited_mobile_app/provider/chapterSection/chapters.dart';
import 'package:narraited_mobile_app/screens/chapter_screen/question_answer_card.dart';
import 'package:narraited_mobile_app/screens/chapter_screen/tts_player.dart';
import 'package:provider/provider.dart';
import '../../provider/chatSection/chatmessages.dart';
import '../../utilities/icons/chat_screen_icons.dart';
import '../../utilities/styles.dart';

class ChapterScreen extends StatefulWidget {
  final String cardTitle;
  final String categoryId;
  final String categoryStatus;
  final int index;

  const ChapterScreen({
    Key? key,
    required this.cardTitle,
    required this.categoryId,
    required this.categoryStatus,
    required this.index,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  bool micVisibile = true;
  String questionAns = "null";
  late TextEditingController editResponseInsert = TextEditingController();

  void _onCardClicked(String text) {
    setState(() {
      questionAns = text;
    });
  }

  bool returnBack() {
    Provider.of<ChapterHistory>(context, listen: false).reset();
    Provider.of<ChapterHistory>(context, listen: false).setNotPlaying();
    Navigator.pop(context);
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChapterHistory>(context, listen: false)
          .setHistory(widget.categoryId);
    });
  }

  Widget openConfirmDelete() {
    return AlertDialog(
      content: const Text('Are you sure you want to delete this conversation?',
          style: Styles.AlertDialogStyle),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('DELETE', style: Styles.AlertDialogRedStyle),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('CANCEL', style: Styles.AlertDialogStyle),
        ),
      ],
    );
  }

  Widget editResponseBottomSheet(
      BuildContext context, String response, String conversationid) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          color: Colors.white),
      margin: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Response',
                  style: Styles.HomeScreen_Style_4,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: const Color(0xff1C75B6),
                  maxLines: null,
                  initialValue: response,
                  onChanged: (value) => editResponseInsert.text = value,
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder()),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          // ignore: prefer_const_constructors
                          Color(0xff1C75B6),
                      elevation: 0.0),
                  child: const Text('Save', style: Styles.HomeScreen_Style_7),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    Provider.of<ChapterHistory>(context, listen: false)
                        .editConv(conversationid, widget.categoryId,
                            editResponseInsert.text);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, elevation: 0.0),
                  child: const Text(
                    'Cancel',
                    style: Styles.HomeScreen_Style_6,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return returnBack();
      },
      child: Consumer2<ChapterHistory, ChaptersList>(
          // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
          builder: (context, ChapterHistory, ChaptersList, child) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                  widget.cardTitle,
                  style: Styles.AppBarStyle,
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.chevron_left_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    returnBack();
                  },
                )),
            body: Visibility(
                visible: ChapterHistory.historyLoadStatus,
                // ignore: sort_child_properties_last
                child: Container(
                    padding: const EdgeInsets.all(15),
                    // height: MediaQuery.of(context).size.height * 0.80,
                    child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemCount: ChapterHistory.historyList.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return openConfirmDelete();
                                      });
                                } else {
                                  return await showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return editResponseBottomSheet(
                                          context,
                                          ChapterHistory
                                              .historyList[index].answer!,
                                          ChapterHistory
                                              .historyList[index].id!);
                                    },
                                  );
                                }
                              },
                              secondaryBackground: Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.centerRight,
                                  child: const Icon(Icons.edit,
                                      color: Colors.green)),
                              background: Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.centerLeft,
                                  child: const Icon(Icons.delete,
                                      color: Colors.redAccent)),
                              key: Key(ChapterHistory.historyList[index].id!),
                              onDismissed: (direction) {
                                if (direction == DismissDirection.startToEnd) {
                                  ChapterHistory.deleteConv(
                                      ChapterHistory.historyList[index].id!,
                                      widget.categoryId,
                                      ChaptersList,
                                      widget.index);
                                }
                              },
                              child: QuestionAnswerCard(
                                question:
                                    ChapterHistory.historyList[index].question!,
                                answer:
                                    ChapterHistory.historyList[index].answer!,
                                isPlaying:
                                    ChapterHistory.historyList[index].isplaying,
                                id: ChapterHistory.historyList[index].id!,
                                onCardClicked: _onCardClicked,
                                chapterHistory: ChapterHistory,
                              ));
                        })
                    // ignore: prefer_const_constructors
                    ),
                replacement: Center(
                  child: Visibility(
                    visible: ChapterHistory.loaderStatus,
                    replacement: const Text("Record your Life chapter"),
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: const Color(0xff1C75B6),
                      size: 25,
                    ),
                  ),
                )),
            bottomNavigationBar: Visibility(
              visible: !ChapterHistory.global,
              // ignore: sort_child_properties_last
              child: Container(
                // margin: const EdgeInsets.all(1),
                height: 80,
                width: double.infinity,
                color: Colors.white,
                child: Stack(
                  children: [
                    Align(
                      alignment: FractionalOffset.center,
                      child: FloatingActionButton(
                          onPressed: () {
                            // Navigator.pushReplacement(context,
                            //     MaterialPageRoute(
                            //   builder: (context) {
                            //     // ignore: prefer_const_constructors
                            //     return ChatScreen(
                            //       categoryId: widget.categoryId,
                            //       categoryStatus: ChaptersList
                            //           .chapterList[widget.index].status!,
                            //       categoryName: widget.cardTitle,
                            //     );
                            //   },
                            // ));
                            Provider.of<ChatMessages>(context, listen: false)
                                .reset();
                          },
                          backgroundColor: const Color(0xff1C75B6),
                          child: const Icon(
                            ChatScreenIcons.mic,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ),
              replacement: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xff1C75B6),
                  ),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  height: 80,
                  width: double.infinity,
                  child: TtsPlayer(questionAnswer: questionAns)),
            ));
      }),
    );
  }
}
