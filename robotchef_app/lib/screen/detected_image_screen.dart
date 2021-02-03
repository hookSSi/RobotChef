import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app/widget/bndbox.dart';
import 'package:flutter_app/class/yolo_server_constants.dart';

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

  @override
  void initState(){
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

  showInSnackBar(content){
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
    _isProcessing = true;

    int startTime = new DateTime.now().millisecondsSinceEpoch;

    FormData formData = new FormData.fromMap({
      "image" : await MultipartFile.fromFile(widget.image.path)
    });

    try{
      var response = await Dio().post(YoloServerContants.endPoint, data: formData);

      if(response.statusCode == 200){
        var result = response.data;
        setRecognitions(result['data'], result['height'], result['width']);
        print("Job took ${(new DateTime.now().millisecondsSinceEpoch - startTime) / 1000} seconds");
      }
    }
    catch(error){
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text("탐지한 재료들"),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            Navigator.pop(context);
          }),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Image.file(widget.image),
            BndBox(
              _recognitions == null ? [] : _recognitions,
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
            ),
          ],
        )
    );
  }
}
