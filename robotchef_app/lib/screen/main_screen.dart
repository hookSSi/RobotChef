import 'package:flutter/material.dart';
import 'package:flutter_app/screen/more_screen.dart';
import 'package:flutter_app/screen/home_screen.dart';
import 'package:flutter_app/screen/search_screen.dart';
import 'package:flutter_app/screen/bookmark_screen.dart';

class MainScreen extends StatelessWidget {
  int selectedPage;
  MainScreen(this.selectedPage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: DefaultTabController(
      initialIndex: selectedPage,
      length: 4,
      child: Scaffold(
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            HomeScreen(),
            SearchScreen(),
            BookmarkScreen(),
            MoreScreen(),
          ],
        ),
      ),
    ),);
  }
}
