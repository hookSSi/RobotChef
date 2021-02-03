import 'package:flutter/material.dart';
import 'package:flutter_app/screen/more_screen.dart';
import 'package:flutter_app/screen/home_screen.dart';
import 'package:flutter_app/screen/search_screen.dart';
import 'package:flutter_app/screen/bookmark_screen.dart';
import 'package:flutter_app/widget/bottom_bar.dart';

class MainScreen extends StatefulWidget {
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isLogined = false;
  TabController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MyApp',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          accentColor: Colors.white,
        ),
        home: DefaultTabController(
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
            bottomNavigationBar: Bottom(),
          ),
        ));
  }
}
