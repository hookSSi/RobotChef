import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app/class/recipe_serach.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/widget/bndbox.dart';
import 'package:flutter_app/class/yolo_server_constants.dart';
import 'package:provider/provider.dart';

class DetectedImageScreen extends StatefulWidget {
  File image;

  DetectedImageScreen(this.image);

  @override
  _DetectedImageScreenState createState() => new _DetectedImageScreenState();
}

class _DetectedImageScreenState extends State<DetectedImageScreen> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  bool _isProcessing = false;
  String _error;

  @override
  void initState() {
    super.initState();
    _processCameraImage();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  showInSnackBar(content) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(content),
        action: SnackBarAction(
            label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void _processCameraImage() async {
    if (_isProcessing) return;

    setState(() {
      _error = null;
      _isProcessing = true;
    });

    int startTime = new DateTime.now().millisecondsSinceEpoch;

    FormData formData = new FormData.fromMap(
        {"image": await MultipartFile.fromFile(widget.image.path)});

    try {
      var response =
          await Dio().post(YoloServerContants.endPoint, data: formData);

      if (response.statusCode == 200) {
        var result = response.data;
        setRecognitions(result['data'], result['height'], result['width']);
        print(
            "Job took ${(new DateTime.now().millisecondsSinceEpoch - startTime) / 1000} seconds");
      }
    } catch (error) {
      print(error.message);
      _error = error.message;
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return Scaffold(
          backgroundColor: Colors.grey,
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                backgroundColor: Colors.black87,
              ),
              SizedBox(
                height: 15,
              ),
              _error == null ? Text("재료 탐지 중...") : Text("error: " + _error)
            ],
          )));
    } else {
      var imageWidget = Image.file(
        widget.image,
      );

      var imageBox = OverflowBox(
        child: imageWidget,
      );

      Size screen = MediaQuery.of(context).size;

      final imageWidth = math.min(_imageHeight, _imageWidth);
      final imageHeight = math.max(_imageHeight, _imageWidth);

      double screenH = _imageHeight * (screen.width / _imageWidth);
      double paddingTop = (screen.height - screenH) / 2;

      return Scaffold(
          backgroundColor: Colors.grey,
          body: Stack(
            children: <Widget>[
              OverflowBox(
                child: imageWidget,
              ),
              BndBox(
                _recognitions == null ? [] : _recognitions,
                paddingTop,
                _imageHeight,
                _imageWidth,
                screenH,
                screen.width,
              ),
              Positioned.fill(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                        onPressed: () {
                          RecipeSearcher searcher = Provider.of<RecipeSearcher>(
                              context,
                              listen: false);
                          List<String> ingredients = List<String>.from(
                              _recognitions
                                  .map((item) => item['detectedClass'])
                                  .toList());
                          searcher.AddIngredients(ingredients);
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.search);
                        },
                        child: Text(
                          "확인",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.black87),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "돌아가기",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.black87,
                    )
                  ],
                ),
              ))
            ],
          ));
    }
  }
}
