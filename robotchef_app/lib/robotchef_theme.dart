import 'package:flutter/material.dart';

ThemeData BuildTheme() {
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
        /// RobotChef 제목에 사용
        headline1: base.headline1.copyWith(
          fontFamily: 'Vegan',
          fontSize: 60.0,
          color: const Color(0xFFE7284A)
        ),
        headline5: base.headline5.copyWith(
          fontFamily: 'Merriweather',
          fontSize: 40.0,
          color: const Color(0xFFE7284A),
        ),
        headline6: base.headline6.copyWith(
          fontFamily: 'Merriweather',
          fontSize: 15.0,
          color: const Color(0xFFE7284A),
        ),
        caption: base.caption.copyWith(
          color: const Color(0xFFE7284A),
        ),
        /// 일반적인 텍스트의 경우에 사용
        bodyText2: base.bodyText2.copyWith(color: const Color(0xFFE7284A))
    );
  }

  final ThemeData base = ThemeData.light();

  return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      primaryColor: const Color(0xFFFEC566),
      primaryColorDark: const Color(0xFFE7284A),
      primaryColorLight: const Color(0xFFFD5C3D),
      iconTheme: IconThemeData(
        color: const Color(0xFFE7284A),
        size: 20.0,
      ),
      buttonColor: const Color(0xFFFFFFFF),
      backgroundColor: const Color(0xFFCCC5AF),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: const Color(0xFFFEC566)
      ),
  );
}