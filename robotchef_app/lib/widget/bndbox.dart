import 'package:flutter/material.dart';
import 'dart:math' as math;

class BndBox extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  BndBox(
      this.results,
      this.previewH,
      this.previewW,
      this.screenH,
      this.screenW,
      );

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBox() {
      return results.map((re) {
        double scaleW =  1 / previewW * screenW;
        double scaleH =  1 / previewH * screenH;

        double _x = re["rect"]["x"].toDouble() * scaleW;
        double _w = re["rect"]["w"].toDouble() * scaleW;
        double _y = re["rect"]["y"].toDouble() * scaleH;
        double _h = re["rect"]["h"].toDouble() * scaleH;

        // if (screenH / screenW > previewH / previewW) {
        //   scaleW = screenH / previewH * previewW;
        //   scaleH = screenH;
        //   var difW = (scaleW - screenW) / scaleW;
        //   x = (_x - difW / 2) * scaleW;
        //   w = _w * scaleW;
        //   if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
        //   y = _y * scaleH;
        //   h = _h * scaleH;
        // } else {
        //   scaleH = screenW / previewW * previewH;
        //   scaleW = screenW;
        //   var difH = (scaleH - screenH) / scaleH;
        //   x = _x * scaleW;
        //   w = _w * scaleW;
        //   y = (_y - difH / 2) * scaleH;
        //   h = _h * scaleH;
        //   if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        // }

        return Positioned(
          left: math.max(0, _x),
          top: math.max(0, _y),
          width: _w,
          height: _h,
          child: Container(
            padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(re['color'][0], re['color'][1], re['color'][2], 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                color: Color.fromRGBO(re['color'][0], re['color'][1], re['color'][2], 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }

    return Stack(
      children: _renderBox(),
    );
  }
}