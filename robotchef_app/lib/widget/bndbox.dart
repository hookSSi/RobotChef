import 'package:flutter/material.dart';
import 'dart:math' as math;

// 이미지의 해상도에 따라 박스가 잘 안그려지는 경우가 있음

class BndBox extends StatelessWidget {
  final List<dynamic> results;
  final double paddingTop;
  final int previewH; // original image size
  final int previewW; // original image size
  final double screenH;
  final double screenW;

  BndBox(this.results,
      this.paddingTop,
      this.previewH,
      this.previewW,
      this.screenH,
      this.screenW,);

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBox() {
      return results.map((re) {
        double scaleW = screenW / previewW;
        double scaleH = screenH / previewH;

        double _x, _w, _y, _h;

        _x = re["rect"]["x"].toDouble() * scaleW;
        _w = re["rect"]["w"].toDouble() * scaleW;
        _y = re["rect"]["y"].toDouble() * scaleH;
        _h = re["rect"]["h"].toDouble() * scaleH;

        /// Container 클래스를 통해 Bounding Box 그림
        return Container(child: Positioned(
          left: math.max(0, _x),
          top: math.max(0, _y + paddingTop),
          width: _w,
          height: _h,
          child: Container(
            padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(
                    re['color'][0], re['color'][1], re['color'][2], 1.0),
                width: 1.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]}: ${(re["confidenceInClass"] * 100)
                  .toStringAsFixed(0)}%",
              style: TextStyle(
                color: Color.fromRGBO(
                    re['color'][0], re['color'][1], re['color'][2], 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),);
      }).toList();
    }

    return Stack(
      children: _renderBox(),
    );
  }
}