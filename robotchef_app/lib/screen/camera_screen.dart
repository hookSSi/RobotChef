import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_app/screen/detected_image_screen.dart';
import 'package:flutter_app/widget/camera.dart';
import 'package:flutter_app/widget/bndbox.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraScreen(this.cameras);

  @override
  _CameraScreenState createState() => new _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<dynamic> _recognitions;
  Set<String> _prevClasses;
  int _duration;
  int _lastTime;
  File _imgFile;
  int _imageHeight = 0;
  int _imageWidth = 0;

  _CameraScreenState() {
    _duration = 3;
    _prevClasses = Set<String>();
  }

  setRecognitions(recognitions, imgFile, imageHeight, imageWidth, currentTime) {
    setState(() {
      _recognitions = recognitions;
      _imgFile = imgFile;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });

    Set<String> currentClasses = new Set<String>();
    _recognitions
        .map((item) => item["detectedClass"])
        .toList()
        .forEach((element) {
      currentClasses.add(element);
    });
    print(currentClasses);

    if (currentClasses.isNotEmpty && _prevClasses.isEmpty) {
      // 처음 객체를 감지한 경우
      _prevClasses = Set<String>.from(currentClasses);
      _lastTime = new DateTime.now().millisecondsSinceEpoch;
    } else if (_prevClasses.isNotEmpty &&
        !currentClasses.containsAll(_prevClasses)) {
      // 이전의 감지한 객체가 있지만 달라진 경우
      _prevClasses = Set<String>.from(currentClasses);
      _lastTime = new DateTime.now().millisecondsSinceEpoch;
    }

    if (_prevClasses.isNotEmpty && currentClasses.containsAll(_prevClasses)) {
      // 감지한 객체가 달라지지 않은 경우
      var t = new DateTime.now().millisecondsSinceEpoch - _lastTime;
      if (_duration < t / 1000) {
        Navigator.pop(context);

        if (_imgFile != null) {
          Navigator.of(context).push(MaterialPageRoute(
              fullscreenDialog: true,
              builder: (BuildContext context) {
                return DetectedImageScreen(_imgFile);
              }));
        }

        // 감지한 객체 검색
        // RecipeSearcher searcher =
        //     Provider.of<RecipeSearcher>(context, listen: false);
        // List<String> ingredients = currentClasses.toList();
        // searcher.addIngredients(ingredients);
        // Navigator.pushNamed(context, AppRoutes.search);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double devicePaddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFABBB64),
          title: Text("촬영 모드", style: TextStyle(color: Colors.white)),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
           iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Camera(
              widget.cameras,
              setRecognitions,
            ),
            BndBox(
              _recognitions == null ? [] : _recognitions,
              -devicePaddingTop,
              _imageHeight,
              _imageWidth,
              screen.height,
              screen.width,
            ),
          ],
        ));
  }
}
