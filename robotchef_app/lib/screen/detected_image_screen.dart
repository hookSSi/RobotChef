import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/class/recipe_search.dart';
import 'package:flutter_app/screen/search_screen.dart';
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
          await Dio().post(YoloServerContants.endPoint, data: formData).timeout(Duration(seconds: 5));

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
      print("에러 출력: ${_error}");
    });
  }

  // 재료 추가 창
  createChooseDialogue(BuildContext context, List<String> ingredientList, Function refresh) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "재료 추가",
              style: TextStyle(color: Colors.black),
            ),
            content: MiniIngredientSearch(
              ingredientList: ingredientList,
              refresh: refresh,
            ),
            backgroundColor: Colors.white,
          );
        });
  }

  void Refresh(){
    setState(() {
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
                backgroundColor: Theme.of(context).primaryColor,
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColorDark),
              ),
              SizedBox(
                height: 15,
              ),
              Text("재료 탐지 중...")
            ],
          )));
    }
    else {
      imageCache.clear();
      var imageWidget = Image.file(
        widget.image,
      );

      if(_error != null){
        // ingredients = ['감자', '계란'];
        // return ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //       primary: Theme.of(context).primaryColor),
        //   onPressed: () {
        //     RecipeSearcher searcher =
        //     Provider.of<RecipeSearcher>(context,
        //         listen: false);
        //     searcher.addIngredients(ingredients);
        //     Navigator.pop(context);
        //     Navigator.of(context).push(MaterialPageRoute(
        //         fullscreenDialog: true,
        //         builder: (BuildContext context) {
        //           return SearchScreen();
        //         }));
        //   },
        //   child: Text(
        //     "확인",
        //     style: Theme.of(context).textTheme.bodyText1,
        //   ),
        // );
        return Text(_error);
      }
      else{
        Size screen = MediaQuery.of(context).size;

        double screenH = _imageHeight * (screen.width / _imageWidth);
        double paddingTop = (screen.height - screenH) / 2;

        return Scaffold(
            backgroundColor: Colors.white,
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
                      child: Column(
                        children: <Widget>[
                          Expanded(child: Container(), flex: _imageHeight + paddingTop.toInt(),),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              child: Row(
                                children: List<Widget>.generate(ingredients.length,
                                        (index) {
                                      return Container(child: InputChip(
                                        label: Text(ingredients[index]),
                                        onDeleted: () {
                                          setState(() {
                                            ingredients.removeAt(index);
                                          });
                                        },
                                      ), margin: EdgeInsets.fromLTRB(3, 0, 3, 0),);
                                    }),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor),
                                onPressed: () {
                                  RecipeSearcher searcher =
                                  Provider.of<RecipeSearcher>(context,
                                      listen: false);
                                  searcher.addIngredients(ingredients);
                                  Navigator.pop(context);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (BuildContext context) {
                                        return SearchScreen();
                                      }));
                                },
                                child: Text(
                                  "확인",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor),
                                onPressed: () {
                                  createChooseDialogue(context, ingredients, Refresh);
                                },
                                child: Text(
                                  "식재료 추가",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "돌아가기",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              )
                            ],
                          ),
                          Expanded(child: Container(), flex: paddingTop.toInt(),),
                        ],
                      ),
                    ))
              ],
            ));
      }
    }
  }
}
