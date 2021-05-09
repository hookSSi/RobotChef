import 'package:flutter/material.dart';

ThemeData BuildTheme() {
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
        headline5: base.headline5.copyWith(
          fontFamily: 'Merriweather',
          fontSize: 40.0,
          color: const Color(0xFF807A6B),
        ),
        // Used for the recipes title:
        headline6: base.headline6.copyWith(
          fontFamily: 'Merriweather',
          fontSize: 15.0,
          color: const Color(0xFF807A6B),
        ),
        // Used for the recipes' duration:
        caption: base.caption.copyWith(
          color: const Color(0xFFCCC5AF),
        ),
        bodyText2: base.bodyText2.copyWith(color: const Color(0xFF807A6B))
    );
  }

  final ThemeData base = ThemeData.light();

  return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      primaryColor: const Color(0xFFFFF8E1),
      indicatorColor: const Color(0xFF807A6B),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      accentColor: const Color(0xFFFFF8E1),
      iconTheme: IconThemeData(
        color: const Color(0xFFCCC5AF),
        size: 20.0,
      ),
      buttonColor: Colors.white,
      backgroundColor: Colors.white,
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: const Color(0xFF807A6B),
        unselectedLabelColor: const Color(0xFFCCC5AF),
      )
  );
}