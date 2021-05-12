import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import '../robotchef_theme.dart';
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
                            color: Theme.of(context).iconTheme.color,
                          ),
                          Text(
                            "실시간",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                      width: 125,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 5.0),
                          color: Theme.of(context).buttonColor),
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
                            color: Theme.of(context).iconTheme.color
                          ),
                          Text(
                            "갤러리",
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      ),
                      width: 125,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 5.0),
                          color: Theme.of(context).buttonColor),
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
                            color: Theme.of(context).iconTheme.color
                          ),
                          Text(
                            "사진 촬영",
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      ),
                      width: 125,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 5.0),
                          color: Theme.of(context).buttonColor),
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              colors: [
                Theme.of(context).primaryColorLight,
                Theme.of(context).primaryColorDark,
              ]
            )
          ),
          child: Column(children: <Widget>[
            /// RobotChef 이미지
            Expanded(child: Center(child: Container(
              child: GradientText(
                'RobotChef',
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFfec566),
                    const Color(0xFFfe921f),
                    Colors.white
                  ]
                ),
                style: Theme.of(context).textTheme.headline1,
              ),
            ),), flex: 1,),
            Expanded(child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              children: <Widget>[
                /// 이미지 선택
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Ink(
                      child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.photo,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        Text(
                          "이미지 선택",
                          style: Theme.of(context).textTheme.bodyText2,
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).buttonColor),
                    ),
                    onTap: () {
                      createChooseDialogue(context);
                    },
                  ),
                ),
                /// 즐겨찾기
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Ink(
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          Text(
                            "즐겨찾기",
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).buttonColor),
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
                /// 검색
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Ink(
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.search,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          Text(
                            "검색",
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).buttonColor),
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
                /// 더 보기
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Ink(
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.list,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          Text(
                            "더 보기",
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).buttonColor),
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
              ],
            ), flex: 2,)
          ]),
          padding: EdgeInsets.all(10.0),
        ));
  }
}