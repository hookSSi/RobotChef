import 'package:flutter/material.dart';

ThemeData BuildTheme() {
  TextTheme _buildTextTheme(TextTheme base) {
    final Shader linearGradient = LinearGradient(colors: [
      const Color(0xFF870a1f),
      const Color(0xFFe7284a),
      const Color(0xFFfd5c3d)
    ]).createShader(Rect.fromLTWH(0.0, 0.0, 350.0, 70.0));

    return base.copyWith(
        /// RobotChef 제목에 사용
        headline1: base.headline1.copyWith(
          fontFamily: 'Vegan',
          fontSize: 60.0,
          foreground: Paint()..shader = linearGradient
        ),
        /// 레시피 타이틀에 사용
        headline4: base.headline4.copyWith(
          fontFamily: 'Hanna',
          fontSize: 30.0,
          color: const Color(0xFFE7284A),
        ),
        /// 영양, 요리순서, 필요한 재료들 같은 부가 제목에 사용
        headline5: base.headline5.copyWith(
          fontFamily: 'Hanna',
          fontSize: 30.0,
          color: const Color(0xFFE7284A),
        ),
        caption: base.caption.copyWith(
          color: const Color(0xFFE7284A),
        ),
        /// 메뉴 텍스트에 사용
        bodyText2: base.bodyText2.copyWith(
            fontFamily: 'Hanna',
            fontSize: 30.0,
            color: const Color(0xFFE7284A)
        ),
        /// 일반적인 텍스트에 사용
        bodyText1: base.bodyText1.copyWith(
            fontFamily: 'Hanna',
            fontSize: 25.0,
            color: const Color(0xFFE7284A)
        )
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
        size: 30.0,
      ),
      buttonColor: const Color(0xFFFFFFFF),
      backgroundColor: const Color(0xFFCCC5AF),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: const Color(0xFFFEC566)
      ),
  );
}