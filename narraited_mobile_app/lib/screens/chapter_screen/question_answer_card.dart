import 'package:flutter/material.dart';
import '../../provider/chapterSection/chapter_history.dart';
import '../../utilities/styles.dart';

class QuestionAnswerCard extends StatefulWidget {
  final String question;
  final ValueChanged<String> onCardClicked;
  final String answer;
  final bool isPlaying;
  final String id;
  final ChapterHistory chapterHistory;

  const QuestionAnswerCard({
    Key? key,
    required this.question,
    required this.answer,
    required this.onCardClicked,
    required this.isPlaying,
    required this.id,
    required this.chapterHistory
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _QuestionAnswerCardState createState() => _QuestionAnswerCardState();
}

class _QuestionAnswerCardState extends State<QuestionAnswerCard> {
  bool volStatus = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.question,
                    style: Styles.ChapterScreen_Style_1,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.answer,
                    style: Styles.ChapterScreen_Style_2,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (widget.isPlaying != true) {
                  widget.chapterHistory.setPlaying(widget.id);
                  String questionAns = "${widget.question} ${widget.answer}";
                  widget.onCardClicked(
                    questionAns,
                  );
                } else {
                  widget.chapterHistory.setNotPlaying();
                  String questionAns = "null";
                  widget.onCardClicked(questionAns);
                }
              },
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: widget.isPlaying
                      ? const Color(0xffFEE600)
                      : const Color(0xffC4C4C4),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.volume_up_outlined,
                  size: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
