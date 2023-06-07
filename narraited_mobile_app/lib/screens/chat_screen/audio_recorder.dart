import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:narraited_mobile_app/utilities/styles.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../../provider/chatSection/chatmessages.dart';

class AudioRecorder extends StatefulWidget {
  final File tempFile;

  const AudioRecorder(
      {Key? key, required this.tempFile})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  late File _file;
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  bool isRecorderStatus = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    initRecorder().then((value) => record());
    _file = widget.tempFile;
  }

  @override
  void dispose() {
    timer?.cancel();
    disposeRecorder();
    super.dispose();
  }

  void disposeRecorder() {
    if (recorder.isRecording) {
      dropRecording().then((value) => recorder.closeRecorder());
    } else {
      recorder.closeRecorder();
    }
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // debugPrint("Microphone permisssion not granted");
      return;
    }
    await recorder.openRecorder();
    setState(() {
      isRecorderReady = true;
    });
    recorder.setSubscriptionDuration(
      const Duration(microseconds: 500),
    );
  }

  Future record() async {
    if (!isRecorderReady) return;
    if (isRecorderStatus == false) {
      String recordingFileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      String filePath = '${_file.path}/$recordingFileName';
      await recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacMP4,
      );
      startTimer();
      setState(() {
        isRecorderStatus = true;
      });
    }
  }

  Future stop() async {
    if (!isRecorderReady) return;
    if (isRecorderStatus == true) {
      final path = await recorder.stopRecorder();
      final audioFile = File(path!);
      String recordingFileName = '${DateTime.now().millisecondsSinceEpoch}.wav';
      String filePath = '${_file.path}/$recordingFileName';
      // ignore: use_build_context_synchronously
      Provider.of<ChatMessages>(context, listen: false)
          .insertAudioText(audioFile, filePath);
      setState(() {
        isRecorderStatus = false;
        _isPaused = false;
      });
    }
  }

  Future pauseRecording() async {
    if (!isRecorderReady) return;
    if (!_isPaused) {
      await recorder.pauseRecorder();
      setState(() {
        _isPaused = true;
      });
    }
  }

  Future resumeRecording() async {
    if (!isRecorderReady) return;
    if (_isPaused) {
      await recorder.resumeRecorder();
      setState(() {
        _isPaused = false;
      });
    }
  }

  Future dropRecording() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    await recorder.deleteRecord(fileName: path!);
  }

  //  timer in recorder

  bool istimerStart = false;
  Duration duration = const Duration();
  Timer? timer;
  void addTime() {
    const addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void resetTimer() {
    setState(() => duration = const Duration());
  }

  void startTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (value) => addTime());
  }

  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    setState(() {
      timer?.cancel();
    });
  }
  // settings for wave animation

  static const _backgroundColor = Colors.transparent;
  static const gradients = [
    [Colors.blue, Color.fromARGB(0, 59, 167, 255)],
    [Colors.white, Color.fromARGB(0, 0, 153, 255)],
    [Colors.blue, Color.fromARGB(47, 0, 140, 255)],
  ];

  static const _durations = [
    6500,
    19440,
    10000,
  ];

  static const _heightPercentages = [
    0.25,
    0.30,
    0.40,
  ];

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
            color: Colors.white),
        height: MediaQuery.of(context).size.height * 0.35,
        child: Center(
            child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: WaveWidget(
                config: CustomConfig(
                  gradients: gradients,
                  gradientBegin: Alignment.topCenter,
                  gradientEnd: Alignment.bottomCenter,
                  durations: _durations,
                  heightPercentages: _heightPercentages,
                ),
                backgroundColor: _backgroundColor,
                size: const Size(double.infinity, 140),
                waveAmplitude: 40.0,
              ),
            ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Visibility(
                    visible: isRecorderStatus,
                    child: Text(
                      '$hours:$minutes:$seconds',
                      style: Styles.HomeScreen_Style_1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: isRecorderStatus,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 40,
                            color: Color(0xff1C75B6),
                          ),
                          onPressed: () async {
                            stopTimer();
                            await dropRecording()
                                .then((value) => Navigator.pop(context));
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            shape: const CircleBorder(),
                            backgroundColor: Colors.white),
                        child: const Icon(
                          Icons.send_outlined,
                          size: 40,
                          color: Color(0xff1C75B6),
                        ),
                        onPressed: () async {
                          if (isRecorderStatus) {
                            stopTimer();
                            await stop()
                                .then((value) => Navigator.pop(context));
                          } else {
                            await record();
                          }
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Visibility(
                        visible: isRecorderStatus,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white),
                          child: Icon(
                            _isPaused
                                ? Icons.play_arrow_outlined
                                : Icons.pause_outlined,
                            size: 40,
                            color: const Color(0xff1C75B6),
                          ),
                          onPressed: () async {
                            if (_isPaused) {
                              startTimer(reset: false);
                              await resumeRecording();
                            } else {
                              stopTimer(reset: false);
                              await pauseRecording();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}
