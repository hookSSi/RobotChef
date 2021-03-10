import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_app/class/yolo_server_constants.dart';
import 'package:flutter_app/service/image_result_processor_service.dart';
import 'dart:math' as math;

import 'package:wakelock/wakelock.dart';

typedef void Callback(List<dynamic> list, int h, int w, int time);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final DELAY_TIME = 160;

  Camera(this.cameras, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera>
    with WidgetsBindingObserver {
  List<StreamSubscription> _subscription = List();
  ImageResultProcessorService _imageResultProcessorService;
  CameraController controller;
  bool _isDetecting = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _imageResultProcessorService = ImageResultProcessorService();
    WidgetsBinding.instance.addObserver(this);
    _subscription.add(_imageResultProcessorService.queue.listen((img) {
      _objectDetectionProcess(img);
    }));

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      _onNewCameraSelected(widget.cameras[0]);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.forEach((element) {
      element.cancel();
    });

    controller?.dispose();
    Wakelock.disable();
    super.dispose();
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller?.dispose();
    }

    controller = new CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    controller.addListener(() {
      if(mounted) setState(() {

      });

      if(controller.value.hasError){
        print("Camera error: ${controller.value.errorDescription}");
      }
    });

    try {
      await controller.initialize();

      await controller.startImageStream((image) => _processCameraImage(image));
    } on CameraException catch (e) {
      // 에러 표시
      // showInSnackBar('Error: ${e.code}\n${e.description}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  // showInSnackBar(content){
  //   final scaffold = Scaffold.of(context);
  //   scaffold.showSnackBar(
  //     SnackBar(
  //       content: Text(content),
  //       action: SnackBarAction(
  //           label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
  //     ),
  //   );
  // }

  void _objectDetectionProcess(Uint8List img) async {
    if (!_isDetecting) {
      _isDetecting = true;

      int startTime = new DateTime.now().millisecondsSinceEpoch;

      FormData formData = new FormData.fromMap({
        "image" : MultipartFile.fromBytes(img, filename: 'uploadImage.jpeg')
      });

      try{
        var response = await Dio().post(YoloServerContants.endPoint, data: formData);

        if(response.statusCode == 200){
              var result = response.data;
              var currentTime = new DateTime.now().millisecondsSinceEpoch;
              widget.setRecognitions(result['data'], result['height'], result['width'], currentTime);
              print("Job took ${(currentTime - startTime) / 1000} seconds");
        }
      }
      catch(error){
        print(error);
      }

      _isDetecting = false;
    }

    _isProcessing = false;
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;
    // 이미지 처리
    await Future.delayed(Duration(milliseconds: widget.DELAY_TIME), () => _imageResultProcessorService.addRawImage(image));
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 15,
              ),
              Text("Loading Camera...")
            ],
          ));
    }

    var tmp = MediaQuery
        .of(context)
        .size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
      screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
      screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
