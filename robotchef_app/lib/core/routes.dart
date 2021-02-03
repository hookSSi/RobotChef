import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screen/login_screen.dart';
import 'package:flutter_app/screen/main_screen.dart';
import 'package:flutter_app/screen/register_screen.dart';

class AppRoutes {
  static const String login = "login";
  static const String register = "register";
  static const String main = "main";
  static const String myApp = "myApp";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    print(settings.name);
    return MaterialPageRoute(
        builder: (context){
          switch(settings.name) {
            case myApp:
              return MyApp();
            case main:
              return MainScreen();
            case register:
              return RegisterScreen();
            case login:
            default:
              return LoginScreen();
          }
        }
    );
  }
}