import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:object_detection/bndbox.dart';
import 'package:object_detection/camera.dart';
import 'dart:math' as math;

class DetectScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String model;

  const DetectScreen({super.key, required this.cameras, required this.model});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  dynamic _mostProminentRecognition;
  int _imageHeight = 0;
  int _imageWidth = 0;

  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    await flutterTts.setLanguage("en-US"); // Set the desired language.
    await flutterTts.setPitch(1.0); // Set the pitch (optional).
    await flutterTts.setVolume(1.0); // Set the volume (optional).
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
      if (recognitions != null && recognitions.isNotEmpty) {
        // Select the first detected object.
        _mostProminentRecognition = recognitions[0];

        // Convert detected class to speech and output it.
        String detectedClass = _mostProminentRecognition['detectedClass'].toString();
        speakDetectedObject(detectedClass);

        Fluttertoast.showToast(
          msg: detectedClass,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        _mostProminentRecognition = null;
      }
    });
  }

  Future<void> speakDetectedObject(String objectName) async {
    await flutterTts.speak("There is a $objectName ahead.");
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Camera(
            widget.cameras,
            widget.model,
            setRecognitions,
          ),
          BndBox(
            _mostProminentRecognition != null ? [_mostProminentRecognition!] : [],
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            screen.height,
            screen.width,
            widget.model,
          ),
        ],
      ),
    );
  }
}
