import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_app/screen/bookmark_screen.dart';
import 'package:flutter_app/screen/camera_screen.dart';
import 'package:flutter_app/screen/detected_image_screen.dart';
import 'package:flutter_app/screen/more_screen.dart';
import 'package:flutter_app/screen/search_screen.dart';
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

    final rotatedFile =
        await FlutterExifRotation.rotateImage(path: pickedFile.path);
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
              "이미지 선택",
              style: TextStyle(color: Colors.black),
            ),
            content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                  Material(
                          child: InkWell(
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.videocam,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "실시간",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              width: 125,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color : Colors.white, width: 5.0),
                                  color: Color(0xFFABBB64)),
                              padding: EdgeInsets.all(20.0),
                            ),
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                              realTimeObjectDetect();
                            },
                          ),
                        ),
                  Material(
                          child: InkWell(
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.photo,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "갤러리",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              width: 125,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color : Colors.white, width: 5.0),
                                  color: Color(0xFFABBB64)),
                              padding: EdgeInsets.all(20.0),
                            ),
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                              takeImageFromGallary();
                            },
                          ),
                        ),
                  Material(
                          child: InkWell(
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "사진 촬영",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              width: 125,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color : Colors.white, width: 5.0),
                                  color: Color(0xFFABBB64)),
                              padding: EdgeInsets.all(20.0),
                            ),
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                              takeImageFromCamera();
                            },
                          ),
                        ),
                ],
              ),
            backgroundColor: Colors.white,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        body:Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Material(
                          child: InkWell(
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Image.asset('images/robotchef.png', width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height * 0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(top:30.0, bottom: 10.0, left: 10.0, right: 10.0),
                ),
                Expanded(
                    child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Material(
                                              child: InkWell(
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.photo,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        "이미지 선택",
                                                        style: TextStyle(color: Colors.white),
                                                      )
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color : Colors.white, width: 5.0),
                                                      color: Color(0xFFABBB64)),
                                                  padding: EdgeInsets.all(20.0),
                                                  alignment: Alignment.center,
                                                ),
                                                onTap: () {
                                                  createChooseDialogue(context);
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Material(
                                              child: InkWell(
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.star,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        "즐겨찾기",
                                                        style: TextStyle(color: Colors.white),
                                                      )
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color : Colors.white, width: 5.0),
                                                      color: Color(0xFFABBB64)),
                                                  padding: EdgeInsets.all(20.0),
                                                  alignment: Alignment.center,
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                      fullscreenDialog: true,
                                                      builder: (BuildContext context) {
                                                        return BookmarkScreen();
                                                      }));
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ]
                              )
                          ),
                          Expanded(
                              child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Material(
                                              child: InkWell(
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.search,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        "검색",
                                                        style: TextStyle(color: Colors.white),
                                                      )
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color : Colors.white, width: 5.0),
                                                      color: Color(0xFFABBB64)),
                                                  padding: EdgeInsets.all(20.0),
                                                  alignment: Alignment.center,
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                      fullscreenDialog: true,
                                                      builder: (BuildContext context) {
                                                        return SearchScreen();
                                                      }));
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Material(
                                              child: InkWell(
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.list,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        "더 보기",
                                                        style: TextStyle(color: Colors.white),
                                                      )
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color : Colors.white, width: 5.0),
                                                      color: Color(0xFFABBB64)),
                                                  padding: EdgeInsets.all(20.0),
                                                  alignment: Alignment.center,
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                      fullscreenDialog: true,
                                                      builder: (BuildContext context) {
                                                        return MoreScreen();
                                                      }));
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ]
                              )
                          ),
                        ]
                    )),
              ]
            ),
          margin: EdgeInsets.all(10.0),
          )
        );
  }
}
