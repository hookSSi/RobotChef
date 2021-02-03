import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  OptionButton({Key key, this.name, this.icon, this.color, this.onPressed}) : super(key: key);
  final String name;
  final IconData icon;
  final Color color;
  final void Function() onPressed;

  Widget build(BuildContext context) {
    return Container(
        height: 120,
        child: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () { this.onPressed(); },
            label: Text(this.name),
            icon: Icon(this.icon),
            backgroundColor: color,
          ),
        )
    );
  }
}
