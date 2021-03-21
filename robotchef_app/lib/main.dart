import 'package:flutter/material.dart';
import 'package:flutter_app/class/providers.dart';
import 'package:flutter_app/screen/login_screen.dart';
import 'package:flutter_app/screen/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/class/auth_state.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> main() async {
  // Required for observing the lifecycle state from the widgets layer.
  WidgetsFlutterBinding.ensureInitialized();
  //Request permission for camera
  PermissionStatus status = await Permission.camera.status;
  while (!status.isGranted) status = await Permission.camera.request();

  // Keep rotation at portrait mode.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          accentColor: Colors.white,
        ),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Consumer<AuthState>(
          builder: (context, state, child) {
            return MainScreen(0);
            // return state.isLoggedIn ? MainScreen(0) : LoginScreen();
          },
        ),
      ),
    );
  }
}