import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/model_recipe.dart';

class CircleIndicator extends StatefulWidget {
  final double percent;
  final Nutrients nutrient;

  CircleIndicator({this.percent = 0.5, this.nutrient});

  @override
  _CircleIndicatorState createState() => _CircleIndicatorState();
}

class _CircleIndicatorState extends State<CircleIndicator>
    with SingleTickerProviderStateMixin {
  double fraction = 0.0;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    var controller = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    animation = Tween(begin: 0.0, end: widget.percent).animate(controller)
      ..addListener(() {
        setState(() {
          fraction = animation.value;
        });
      });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Container(
            width: 70,
            height: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    widget.nutrient.name,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                ),
                Container(
                  child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    widget.nutrient.weight,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            child: CustomPaint(
              foregroundPainter: CirclePainter(fraction),
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  Paint _paint;
  Paint _backgroundPaint;
  double _fraction;

  CirclePainter(this._fraction) {
    _paint = Paint()
      ..color = Color(0xffbf6b11)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _backgroundPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset(0.0, 0.0) & size;
    canvas.drawArc(rect, -pi / 2, pi * 2, false, _backgroundPaint);
    canvas.drawArc(rect, -pi / 2, pi * 2 * _fraction, false, _paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}
