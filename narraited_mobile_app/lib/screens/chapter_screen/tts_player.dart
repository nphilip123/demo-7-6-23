import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:narraited_mobile_app/utilities/styles.dart';

import '../../provider/chapterSection/chapter_history.dart';

class TtsPlayer extends StatefulWidget {
  final String questionAnswer;

  const TtsPlayer({Key? key, required this.questionAnswer}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TtsPlayerState createState() => _TtsPlayerState();
}

class _TtsPlayerState extends State<TtsPlayer> {
  bool isplaying = false;
  bool isDataLoaded = false;
  final audioPlayer = AudioPlayer();
  late Uint8List audioData;
  Uint8List? get bytesSource => null;

  @override
  void initState() {
    getAudio();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TtsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    String previousParameter = "null";
    if (widget.questionAnswer != previousParameter) {
      previousParameter = widget.questionAnswer;
      getAudio();
    }
  }

  void getAudio() async {
    final data = await ChapterHistory.ttsConversion(widget.questionAnswer);
    if (data is String) {
      setState(() {
        isDataLoaded = false;
      });
    } else {
      audioData = Uint8List.fromList(data as List<int>);
      audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.setSourceBytes(audioData);
      if (!mounted) {
        return; 
      }
      setState(() {
        isDataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Visibility(
          visible: isDataLoaded,
          // ignore: sort_child_properties_last
          child: ElevatedButton(
            onPressed: () async {
              if (isplaying != true) {
                await audioPlayer.resume();
                setState(() {
                  isplaying = true;
                });
              } else {
                audioPlayer.pause();
                setState(() {
                  isplaying = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor:
                  Colors.white, 
            ),
            child: Icon(isplaying ? Icons.pause : Icons.play_arrow,color: const Color(
                                0xff1C75B6)),
          ),
          replacement: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 2,
          child: Text(
            widget.questionAnswer,
            overflow: TextOverflow.ellipsis,
            style: Styles.ChapterScreen_Style_3,
          ),
        ),
        // const Text("00:00"),
      ],
    );
  }
}
