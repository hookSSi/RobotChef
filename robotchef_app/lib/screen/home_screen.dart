import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/camera_screen.dart';
import 'package:flutter_app/screen/detected_image_screen.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File _image;
  final picker = ImagePicker();

  Future getImage(ImageSource imageSource) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: imageSource, imageQuality: 50);

    final rotatedFile = await FlutterExifRotation.rotateImage(path: pickedFile.path);
    setState(() {
      if (pickedFile != null) {
        _image = rotatedFile;
      } else {
        print('No image selected');
      }
    });
  }

  realTimeObjectDetect() async {
    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
    }

    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return CameraScreen(cameras);
        }));
  }

  takeImageFromGallary() async {
    await getImage(ImageSource.gallery);

    if (_image != null) {
      Navigator.of(context).push(MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) {
            return DetectedImageScreen(_image);
          }));
    }
  }

  takeImageFromCamera() async {
    await getImage(ImageSource.camera);

    if (_image != null) {
      Navigator.of(context).push(MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) {
            return DetectedImageScreen(_image);
          }));
    }
  }

  createChooseDialogue(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "선택",
              style: TextStyle(color: Colors.blue),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Material(
                  child: InkWell(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.photo,
                            color: Colors.blue,
                          ),
                          Text(
                            "갤러리",
                            style: TextStyle(color: Colors.blue),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle, color: Colors.transparent),
                      padding: EdgeInsets.all(20.0),
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      takeImageFromGallary();
                    },
                  ),
                  color: Colors.white,
                ),
                Material(
                  child: InkWell(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.blue,
                          ),
                          Text(
                            "사진 촬영",
                            style: TextStyle(color: Colors.blue),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle, color: Colors.transparent),
                      padding: EdgeInsets.all(20.0),
                    ),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      takeImageFromCamera();
                    },
                  ),
                  color: Colors.white,
                )
              ],
            ),
            backgroundColor: Colors.white,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(children: [Text('Robot Chef  '), Icon(Icons.tv)])),
        body: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          child: InkWell(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.videocam,
                                    color: Colors.black87,
                                  ),
                                  Text(
                                    "실시간",
                                    style: TextStyle(color: Colors.black87),
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent),
                              padding: EdgeInsets.all(20.0),
                              alignment: Alignment.center,
                            ),
                            onTap: () {
                              realTimeObjectDetect();
                              print("tab");
                            },
                          ),
                          color: Colors.white60,
                        ),
                        flex: 10,
                      )
                    ],
                  ),
                  flex: 5,
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Material(
                          child: InkWell(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.photo,
                                    color: Colors.white60,
                                  ),
                                  Text(
                                    "이미지 선택",
                                    style: TextStyle(color: Colors.white60),
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent),
                              padding: EdgeInsets.all(20.0),
                              alignment: Alignment.center,
                            ),
                            onTap: () {
                              createChooseDialogue(context);
                            },
                          ),
                          color: Colors.black26,
                        ),
                        flex: 10,
                      )
                    ],
                  ),
                  flex: 5,
                ),
              ],
            ),
          ),
        ));
  }
}
