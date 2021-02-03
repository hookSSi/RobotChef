import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/class/auth_state.dart';
import 'package:flutter_app/core/routes.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:flutter_app/screen/detail_screen.dart';
import 'package:provider/provider.dart';

class MoreScreen extends StatefulWidget {
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  Recipe recipe = Recipe.fromMap({
    'recipe_id': "44",
    'title': "Test 레시피",
    'sumry': "레시피 테스트 중",
    'image':
    "https://cloudfront.haemukja.com/vh.php?url=https://d1hk7gw6lgygff.cloudfront.net/uploads/direction/image_file/3401/org_resized_0.png&convert=jpgmin&rt=600",
    'cooking_time': "60분",
    'calorie': "461.3 kcal",
    'ingredients': [
      {"name": "홍합", "amount": "1 kg"},
      {"name": "청주", "amount": "1.5스푼"}
    ],
    'instructions': [
      {
        "proc_num": 1,
        "desc": "런던의 유명음식점 중에.. 벨고라는...",
        "image": "images/test.jpg"
      },
      {"proc_num": 2, "desc": "계란후라이는 정말 맛있다...", "image": "images/test.jpg"}
    ],
    'like': false
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '더 보기',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          accentColor: Colors.white,
        ),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Scaffold(
          appBar: AppBar(title: Row(children: [Text('더 보기  ')])),
          body: Consumer<AuthState>(builder: (context, state, child) {
            if (!state.isLoggedIn) {
              return Container();
            }
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Center(
                    child: Text(
                      state.user.name ?? '',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline4,
                    )),
                Center(child: Text(state.user.email)),
                Center(
                  child: RaisedButton(
                    onPressed: () async {
                      await state.logout();
                      runApp(MyApp());
                    },
                    child: Text("Log Out"),
                  ),
                ),
                Center(
                    child: Container(
                      child: Hero(
                          tag: recipe.recipe_id,
                          child: Material(
                            child: IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (BuildContext context) {
                                      return DetailScreen(recipe: recipe);
                                    }));
                                print(recipe.toString());
                              },
                            ),
                          )),
                    ))
              ],
            );
          }),
        ));
  }
}
