import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/class/recipe_search.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/widget/bndbox.dart';
import 'package:flutter_app/class/yolo_server_constants.dart';
import 'package:flutter_app/widget/mini_ingredient_search.dart';
import 'package:provider/provider.dart';

class DetectedImageScreen extends StatefulWidget {
  final File image;

  DetectedImageScreen(this.image);

  @override
  _DetectedImageScreenState createState() => new _DetectedImageScreenState();
}

class _DetectedImageScreenState extends State<DetectedImageScreen> {
  List<dynamic> _recognitions;
  List<String> ingredients;
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
    final scaffold = ScaffoldMessenger.of(context);
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
        print("Job took ${(new DateTime.now().millisecondsSinceEpoch - startTime) / 1000} seconds");
        ingredients = List<String>.from(
            _recognitions
                .map((item) => item['detectedClass'])
                .toList());
      }
    } catch (error) {
      print(error.message);
      _error = error.message;
    }

    setState(() {
      _isProcessing = false;
    });
  }

  // 재료 추가 창
  createChooseDialogue(BuildContext context, List<String> ingredientList) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "재료 추가",
              style: TextStyle(color: Colors.black),
            ),
            content: MiniIngredientSearch(ingredientList: ingredientList,),
            backgroundColor: Colors.white,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return Scaffold(
          backgroundColor: Color(0xFFEEE8AA),
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

      Size screen = MediaQuery.of(context).size;

      double screenH = _imageHeight * (screen.width / _imageWidth);
      double paddingTop = (screen.height - screenH) / 2;

      return Scaffold(
          backgroundColor: Color(0xFFEEE8AA),
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
              ListView(
                scrollDirection: Axis.horizontal,
              ),
              Positioned.fill(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        RecipeSearcher searcher =
                            Provider.of<RecipeSearcher>(context, listen: false);
                        searcher.addIngredients(ingredients);
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.search);
                      },
                      child: Text(
                        "확인",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        createChooseDialogue(context, ingredients);
                      },
                      child: Text(
                        "식재료 추가",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "돌아가기",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ))
            ],
          ));
    }
  }
}
