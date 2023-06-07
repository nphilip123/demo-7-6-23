import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:narraited_mobile_app/utilities/styles.dart';

class AudioPlayer extends StatefulWidget {
  final String audioText;
  final File filepath;
  final String time;

  const AudioPlayer({Key? key, required this.filepath, required this.audioText,required this.time})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  @override
  void initState() {
    super.initState();
    playerInit();
  }

  @override
  void dispose() {
    playerDispose();
    super.dispose();
  }

  bool isPlaying = false;
  // ignore: prefer_const_constructors
  Duration _position = Duration();
  // ignore: prefer_const_constructors
  Duration _duration = Duration();

  FlutterSoundPlayer? _audioPlayer;

  Future _play(VoidCallback whenFinished) async {
    if (await widget.filepath.exists()) {
      try {
        await _audioPlayer!.startPlayer(
          fromURI: widget.filepath.path,
          whenFinished: whenFinished,
        );
        setState(() {
          isPlaying = true;
        });
      } on Exception catch (e) {
        debugPrint(e as String?);
      }
    }
  }

  Future _stop() async {
    await _audioPlayer!.stopPlayer();
    setState(() {
      isPlaying = false;
    });
  }

  Future togglePlaying({required VoidCallback whenFinished}) async {
    if (_audioPlayer!.isStopped) {
      await _play(whenFinished);
    } else {
      await _stop();
    }
  }

  Future playerInit() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();
    _audioPlayer!.setSubscriptionDuration(const Duration(milliseconds: 100));
    _audioPlayer!.onProgress!.listen((e) {
      setState(() {
        _position = e.position;
        _duration = e.duration;
      });
    });
  }

  Future playerDispose() async {
    _audioPlayer!.closePlayer();
    _audioPlayer = null;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.time,
              style: const TextStyle(fontSize: 10),
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
        Bubble(
            margin: const BubbleEdges.all(7),
            // ignore: prefer_const_constructors
            radius: Radius.circular(15.0),
            color: const Color(0xff1C75B6),
            elevation: 0.0,
            child: Padding(
                // ignore: prefer_const_constructors
                padding: EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                            child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 250),
                                child: Row(
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      // ignore: prefer_const_constructors
                                      icon: Icon(
                                        isPlaying
                                            ? Icons.stop
                                            : Icons.play_arrow,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        await togglePlaying(whenFinished: () {
                                          setState(() {
                                            isPlaying = false;
                                          });
                                        });
                                      },
                                    ),
                                    SliderTheme(
                                      data: const SliderThemeData(
                                        trackHeight: 2,
                                        thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 0),
                                      ),
                                      child: Slider(
                                        activeColor: Colors.white,
                                        inactiveColor: const Color.fromARGB(
                                            160, 83, 83, 83),
                                        thumbColor: Colors.white,
                                        value: _position.inSeconds.toDouble(),
                                        min: 0.0,
                                        max: _duration.inSeconds.toDouble(),
                                        onChanged: (value) {
                                          setState(() {
                                            _position = Duration(
                                                seconds: value.toInt());
                                          });
                                        },
                                        onChangeEnd: (value) async {
                                          await _audioPlayer!
                                              .seekToPlayer(_position);
                                        },
                                      ),
                                    ),
                                    Text(
                                      formatTime(_position),
                                      style: Styles.ChatbubbleStyle2,
                                    ),
                                  ],
                                )))
                      ],
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: Text(
                        widget.audioText,
                        style: Styles.ChatbubbleStyleUser,
                      ),
                    )
                  ],
                ))),
      ],
    );
  }
}
