import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:flutter_app/widget/circle_indicator.dart';
import 'package:flutter_app/class/app_constants.dart';
import 'package:flutter_app/class/db_manager.dart';

// 레시피의 상세 화면을 만드는 스크린
class DetailScreen extends StatefulWidget {
  final Recipe recipe;

  DetailScreen({this.recipe});

  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool like = false;

  Future<bool> addBookmark(int recipe_id) async {
    var res =
        await DBManager.Instance.AddData(AppConstants.bookmarkDoc, recipe_id);
    print(res);
    return true;
  }

  Future<bool> removeBookmark(int recipe_id) async {
    var res = await DBManager.Instance.DeleteData(
        AppConstants.bookmarkDoc, recipe_id);
    print(res);
    return true;
  }

  Future<bool> getBookmark(int recipe_id) async {
    var res =
        await DBManager.Instance.GetData(AppConstants.bookmarkDoc, recipe_id);
    return res;
  }

  @override
  void initState() {
    super.initState();
    int recipe_id = int.tryParse(widget.recipe.recipe_id);
    Future<bool> result = getBookmark(recipe_id);
    result.then((value) => setState(() {
          like = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: widget.recipe.recipe_id,
                  child: FadeInImage(
                    image: NetworkImage(widget.recipe.thumbnail),
                    fit: BoxFit.cover,
                    placeholder: AssetImage('images/loading.gif'),
                  ),
                ),
              ),
            )
          ];
        },
        body: Container(
          color: Color(0xFFFFFFFF),
          padding: EdgeInsets.only(top: 8.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Material(
              color: Color(0xFFABBB64),
              child: Column(
                children: <Widget>[
                  // 레시피 제목
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.recipe.title,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                        textAlign: TextAlign.center,
                      ),
                      like
                          ? IconButton(
                              color: Color(0xFFFFFFFF),
                              icon: Icon(Icons.star),
                              onPressed: () {
                                int recipe_id =
                                    int.tryParse(widget.recipe.recipe_id);
                                Future<bool> isEnd = removeBookmark(recipe_id);
                                isEnd.then((value) => setState(() {
                                      like = false;
                                    }));
                              })
                          : IconButton(
                              color: Color(0xFFFFFFFF),
                              icon: Icon(Icons.star_border),
                              onPressed: () {
                                int recipe_id =
                                    int.tryParse(widget.recipe.recipe_id);
                                Future<bool> isEnd = addBookmark(recipe_id);
                                isEnd.then((value) => setState(() {
                                      like = true;
                                    }));
                              })
                    ],
                  )),
                  Divider(),
                  // 레시피 영양 정보
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text('영양',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        CalorieWidget(
                          calorie: widget.recipe.calorie,
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  // 필요한 재료들
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text('필요한 재료들',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        IngredientsWidget(
                          ingredients: widget.recipe.ingredients,
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  // 레시피 순서
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text('요리순서',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        RecipeSteps(
                          instructions: widget.recipe.instructions,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecipeSteps extends StatelessWidget {
  final List<Instruction> instructions;

  RecipeSteps({this.instructions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: instructions.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                child: Text('${index + 1}',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInImage(
                    placeholder: AssetImage('images/loading.gif'),
                    image: NetworkImage(instructions[index].image),
                    width: 200,
                    height: 100,
                  ),
                  Text(instructions[index].desc,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class IngredientsWidget extends StatelessWidget {
  final List<Ingredient> ingredients;

  IngredientsWidget({this.ingredients});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ListView.builder(
        itemCount: ingredients.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              backgroundColor: Theme.of(context).accentColor,
              label: Text(
                  ingredients[index].amount + " " + ingredients[index].name,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

class CalorieWidget extends StatelessWidget {
  final Nutrients calorie;

  CalorieWidget({this.calorie});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      width: double.infinity,
      child: ListView.builder(
        itemCount: 1,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return CircleIndicator(
            percent: calorie.percent,
            nutrient: calorie,
          );
        },
      ),
    );
  }
}
