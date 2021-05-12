import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:flutter_app/screen/detail_screen.dart';
import 'package:flutter_app/widget/mini_ingredient_search.dart';

class MoreScreen extends StatefulWidget {
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  List<String> ingredientList = [];

  // recip 정보 테스트 용
  Recipe recipe = Recipe.fromMap({
    'recipe_id': "44",
    'title': "Test 레시피",
    'sumry': "레시피 테스트 중",
    'image':
        "https://cloudfront.haemukja.com/vh.php?url=https://d1hk7gw6lgygff.cloudfront.net/uploads/direction/image_file/3401/org_resized_0.png&convert=jpgmin&rt=600",
    'cooking_time': "60분",
    'calorie': "4601.3kcal",
    'ingredients': [
      {"name": "홍합", "amount": "1 kg"},
      {"name": "홍합", "amount": "1 kg"},
      {"name": "홍합", "amount": "1 kg"},
      {"name": "청주", "amount": "1.5스푼"},
      {"name": "청주", "amount": "1.5스푼"},
      {"name": "청주", "amount": "1.5스푼"}
    ],
    'instructions': [
      {
        "proc_num": 1,
        "desc": "런던의 유명음식점 중에.. 벨고라는...",
        "image":
            "https://cloudfront.haemukja.com/vh.php?url=https://d1hk7gw6lgygff.cloudfront.net/uploads/direction/image_file/3401/org_resized_0.png&convert=jpgmin&rt=600"
      },
      {
        "proc_num": 2,
        "desc": "계란후라이는 정말 맛있다...",
        "image":
            "https://cloudfront.haemukja.com/vh.php?url=https://d1hk7gw6lgygff.cloudfront.net/uploads/direction/image_file/3401/org_resized_0.png&convert=jpgmin&rt=600"
      }
    ],
    'like': false
  });
  
  // 재료 추가 창
  createChooseDialogue(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "재료 추가",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            content: MiniIngredientSearch(ingredientList: ingredientList,),
            backgroundColor: Theme.of(context).backgroundColor,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('더 보기 ', style: Theme.of(context).textTheme.bodyText1,),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          iconTheme: Theme.of(context).iconTheme),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // 레시피 디테일 UI 테스트 용
          Center(
              child: Container(
                  child: Hero(
                tag: recipe.recipeId,
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
          ),),
          // 미니 재료 검색 dialog 테스트용
          Center(
            child: Container(
                child: IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    createChooseDialogue(context);
                  },
                )
            ),)
        ],
      ),
    );
  }
}
