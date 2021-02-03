import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Core/routes.dart';
import 'package:flutter_app/class/auth_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef void LoginCallback(bool value) ;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _storage = new FlutterSecureStorage();
  bool isAutoLogin = false;

  login() {
    AuthState state = Provider.of<AuthState>(context, listen: false);

    if (isAutoLogin) {
      state.saveLoginInfo(_email.text, _password.text);
    }

    state.login(_email.text, _password.text);

    if(!state.isLoggedIn) {
      showInSnackBar(state.error);
    }
  }

  autoLogin() async {
    _email.text = await _storage.read(key: "email");
    _password.text = await _storage.read(key: "password");

    if (_email.text != "") {
      login();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    autoLogin();
  }

  showInSnackBar(content){
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(content),
        action: SnackBarAction(
            label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                  width: 200,
                  height: 150,
                  child: Image.asset('images/test.jpg'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: "이메일을 입력하세요."),
                controller: _email,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: "비밀번호를 입력하세요"),
                controller: _password,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(10)),
                  child: FlatButton(
                    onPressed: () {
                      login();
                    },
                    child: Text(
                      '로그인',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  )),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    RichText(text: TextSpan(text: "계정 기억하기")),
                    Checkbox(
                        value: isAutoLogin,
                        onChanged: (value) {
                          setState(() {
                            isAutoLogin = value;
                          });
                        })
                  ],
                )),
            Padding(
              padding: const EdgeInsets.all(10),
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(text: "계정이 없으신가요? "),
                TextSpan(
                    text: "계정 만들기",
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      })
              ])),
            )
          ],
        ),
      ),
    );
  }
}
