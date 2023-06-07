import 'package:flutter/material.dart';
import 'package:narraited_mobile_app/utilities/icons/home_screen_icons_icons.dart';
import 'package:narraited_mobile_app/utilities/styles.dart';
import 'package:provider/provider.dart';

import '../../provider/chapterSection/chapters.dart';
import '../chapter_screen/chapter_screen.dart';

class LifeEventCard extends StatefulWidget {
  const LifeEventCard(
      {Key? key,
      required this.categoryId,
      required this.cardTitle,
      required this.cardColor,
      required this.index,
      required this.status})
      : super(key: key);
  final String categoryId;
  final int index;
  final String status;
  final String cardTitle;
  final String cardColor;
  @override
  // ignore: library_private_types_in_public_api
  _LifeEventCardState createState() => _LifeEventCardState();
}

class _LifeEventCardState extends State<LifeEventCard> {
  late TextEditingController renameInsert = TextEditingController();

  Future openDeleteConfirm() => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            "Delete ${widget.cardTitle} ?",
            style: Styles.AlertDialogStyle,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Provider.of<ChaptersList>(context, listen: false)
                      .deleteChapter(widget.index, widget.categoryId);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Delete",
                  style: Styles.AlertDialogRedStyle,
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel", style: Styles.AlertDialogStyle))
          ],
        );
      });

  Widget chapterOptionsBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          color: Colors.white),
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Text(
              widget.cardTitle,
              style: Styles.HomeScreen_Style_4,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                    visible: widget.status == "IN PROGRESS",
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, elevation: 0.0),
                      onPressed: () {
                        Provider.of<ChaptersList>(context, listen: false)
                            .setChapterStatusComplete(widget.categoryId);
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.done_all, color: Colors.black),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Mark as Completed',
                            style: Styles.HomeScreen_Style_3,
                          )
                        ],
                      ),
                    )),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, elevation: 0.0),
                  child: Row(children:const [
                    Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text('Rename', style: Styles.HomeScreen_Style_3)
                  ]),
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: renameBottomSheet(context),
                        );
                      },
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, elevation: 0.0),
                  child: Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Delete',
                        style: Styles.HomeScreen_Style_3,
                      )
                    ],
                  ),
                  onPressed: () {
                    openDeleteConfirm().then((value) => Navigator.pop(context));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget renameBottomSheet(BuildContext context) {
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
                  'Rename',
                  style: Styles.HomeScreen_Style_4,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  cursorColor: const Color(0xff1C75B6),
                  initialValue: widget.cardTitle,
                  onChanged: (value) => renameInsert.text = value,
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
                  child: const Text('Update', style: Styles.HomeScreen_Style_7),
                  onPressed: () {
                    if (renameInsert.text.isNotEmpty) {
                      Provider.of<ChaptersList>(context, listen: false)
                          .renameChapter(widget.index, renameInsert.text,
                              widget.status, widget.categoryId,widget.cardColor);
                      renameInsert.clear();
                    }
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, elevation: 0.0),
                  child: const Text(
                    'Cancel',
                    style: Styles.HomeScreen_Style_6,
                  ),
                  onPressed: () => Navigator.pop(context),
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
    // ignore: prefer_const_constructors
    return AspectRatio(
        aspectRatio: 1.0,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            clipBehavior: Clip.hardEdge,
            color: const Color(0xffF4F4F4),
            elevation: 0.0,
            child: GestureDetector(
                onHorizontalDragStart: (details) => {
                      showModalBottomSheet<void>(
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return chapterOptionsBottomSheet();
                        },
                      )
                    },
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ChapterScreen(
                        cardTitle: widget.cardTitle,
                        categoryId: widget.categoryId,
                        categoryStatus: widget.status,
                        index: widget.index);
                  }));
                },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Color(int.parse(widget.cardColor)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  "${widget.index+1}. ${widget.cardTitle}",
                                  style: Styles.HomeScreen_Style_5,
                                ),
                              ),
                              const Expanded(
                                child: Icon(
                                  HomeScreenIcons.cardmenu,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (widget.status == "TO DO")
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.status,
                                style: Styles.ChapterStatus_todo,
                              ),
                            ),
                          if (widget.status == "IN PROGRESS")
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.status,
                                style: Styles.ChapterStatus_onprogress,
                              ),
                            ),
                          if (widget.status == "COMPLETED")
                            Container(
                              padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.status,
                                style: Styles.ChapterStatus_completed,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(child: Image.asset('assets/images/cardWave.png'))
                  ],
                ))));
  }
}
