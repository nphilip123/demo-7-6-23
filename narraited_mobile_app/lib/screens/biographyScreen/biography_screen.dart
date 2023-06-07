// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:narraited_mobile_app/provider/biographySection/biography_controller.dart';
import 'package:narraited_mobile_app/utilities/styles.dart';

import '../../provider/chapterSection/chapter_history.dart';

class BiographyScreen extends StatefulWidget {
  const BiographyScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BiographyScreenState createState() => _BiographyScreenState();
}

class _BiographyScreenState extends State<BiographyScreen> {
  String dataText = '';
  bool isplaying = false;
  bool isAudioLoaded = false;
  bool isDataLoaded = false;
  late Uint8List audioData;
  final audioPlayer = AudioPlayer();

  Duration _position = Duration.zero;

  Duration _duration = Duration.zero;

  late StreamSubscription<PlayerState> playerStateSubscription;
  late StreamSubscription<Duration> durationSubscription;
  late StreamSubscription<Duration> positionSubscription;
  @override
  void initState() {
    super.initState();

    setText().then((value) => getAudio(value));
    // getAudio();
    playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isplaying = event == PlayerState.playing;
      });
    });

    durationSubscription = audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        _duration = event;
      });
    });

    positionSubscription = audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        _position = event;
      });
    });
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    durationSubscription.cancel();
    positionSubscription.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  void getAudio(String dataText) async {
    final data = await ChapterHistory.ttsConversion(dataText);
    if (data is String) {
      setState(() {
        isAudioLoaded = false;
      });
    } else {
      audioData = Uint8List.fromList(data as List<int>);
      audioPlayer.setReleaseMode(ReleaseMode.stop);
      await audioPlayer.setSourceBytes(audioData);
      if (!mounted) {
        return;
      }
      setState(() {
        isAudioLoaded = true;
      });
    }
  }

  Future<String> setText() async {
    var data = await BiographyController.generateFullBiography();
    if (data != "Error") {
      if (data['Biography'] != "EMPTY") {
        // ignore: use_build_context_synchronously, prefer_typing_uninitialized_variables
        var temp = "";
        for (var categoryBiography in data['Biography']) {
          temp = temp +
              categoryBiography['categoryName'] +
              '\n\n' +
              categoryBiography['Biography'] +
              '\n\n';
        }
        if (mounted) {
          setState(() {
            dataText = temp;
            isDataLoaded = true;
          });
        }
        return data['Speech'];
      } else {
        setState(() {
          dataText = "Record Your Life Chapters to generate biography";
          isDataLoaded = true;
        });
        return "Record Your Life Chapters to generate biography";
      }
      // getAudio();
    }
    if (mounted) {
      setState(() {
        dataText = "Error in fetching Biography";
      });
    }
    return "error";
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            AppBar(
                backgroundColor: Colors.black,
                centerTitle: true,
                title: const Text("Generated Biography"),
                leading: IconButton(
                  icon: const Icon(
                    Icons.expand_circle_down_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(
              height: 20,
            ),
            Visibility(
                visible: isDataLoaded,
                replacement: Expanded(
                    child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: const Color(0xff1C75B6),
                    size: 25,
                  ),
                )),
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      dataText,
                      style: Styles.BiographyScreen_Style_1,
                    ),
                  ),
                )),
            Column(
              children: [
                SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 2,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
                  ),
                  child: Slider(
                    divisions: 4,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    thumbColor: Colors.black,
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await audioPlayer.seek(position);
                      await audioPlayer.resume();
                    },
                  ),
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      formatTime(_position),
                      style: Styles.BiographyScreen_Style_2,
                    ),
                    const Spacer(),
                    Text(
                      formatTime(_duration - _position),
                      style: Styles.BiographyScreen_Style_2,
                    ),
                  ],
                ),
                Visibility(
                    visible: isAudioLoaded,
                    replacement: LoadingAnimationWidget.staggeredDotsWave(
                      color: const Color(0xff1C75B6),
                      size: 25,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
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
                            backgroundColor: const Color(
                                0xff1C75B6), // Set your desired background color
                          ),
                          // ignore: prefer_const_constructors
                          child: Icon(
                            isplaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
