import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:flutter_app/widget/circle_indicator.dart';
import 'package:flutter_app/class/app_constants.dart';
import 'package:flutter_app/class/db_manager.dart';

// 레시피의 상세 화면을 만드는 스크린
class DetailScreen extends StatefulWidget {
  final Recipe recipe;
  final Function onPop;

  DetailScreen({this.recipe, this.onPop});

  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool like = false;

  Future<bool> bookmark(int recipeId) async {
    if (!like) {
      await DBManager.getInstance.addData(AppConstants.bookmarkDoc, recipeId);
      return true;
    } else {
      await DBManager.getInstance
          .deleteData(AppConstants.bookmarkDoc, recipeId);
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.recipe.getBookmark().then((value) => setState(() {
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
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              actions: [
                IconButton(
                    icon: like
                        ? Icon(
                            Icons.favorite,
                            color: Theme.of(context).iconTheme.color,
                          )
                        : Icon(
                            Icons.favorite_border,
                            color: Theme.of(context).iconTheme.color,
                          ),
                    onPressed: () {
                      int recipeId = int.tryParse(widget.recipe.recipeId);
                      Future<bool> isEnd = bookmark(recipeId);
                      isEnd.then((value) => setState(() {
                            like = value;
                          }));
                    })
              ],
              backgroundColor: Theme.of(context).backgroundColor,
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: widget.recipe.recipeId,
                  child: FadeInImage(
                    image: NetworkImage(widget.recipe.thumbnail),
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/images/loading.gif'),
                  ),
                ),
              ),
            )
          ];
        },
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Material(
              color: Theme.of(context).primaryColor,
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    // 레시피 제목
                    Container(
                        child: Wrap(children: <Widget>[
                      Text(
                        widget.recipe.title,
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center,
                      )
                    ])),
                    Divider(
                      height: 30.0,
                      color: Theme.of(context).iconTheme.color,
                      thickness: 3.0,
                    ),
                    // 레시피 영양 정보
                    Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '영양',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ],
                          ),
                          CalorieWidget(calorie: widget.recipe.calorie),
                        ],
                      ),
                    ),
                    Divider(
                      height: 30.0,
                      color: Theme.of(context).iconTheme.color,
                      thickness: 3.0,
                    ),
                    // 필요한 재료들
                    Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('필요한 재료들',
                                  style: Theme.of(context).textTheme.headline5),
                            ],
                          ),
                          IngredientsWidget(
                            ingredients: widget.recipe.ingredients,
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 30.0,
                      color: Theme.of(context).iconTheme.color,
                      thickness: 3.0,
                    ),
                    // 레시피 순서
                    Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('요리순서',
                                  style: Theme.of(context).textTheme.headline5),
                            ],
                          ),
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
        return Container(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Wrap(
                direction: Axis.horizontal,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text('${index + 1}',
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FadeInImage(
                        placeholder: AssetImage('images/loading.gif'),
                        image: NetworkImage(instructions[index].image),
                        width: MediaQuery.of(context).size.width - 34,
                        height: MediaQuery.of(context).size.height / 2,
                        fit: BoxFit.fill,
                      ),
                      Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 34),
                          child: Text(instructions[index].desc,
                              style: Theme.of(context).textTheme.bodyText1))
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class IngredientsWidget extends StatelessWidget {
  final List<Ingredient> ingredients;

  IngredientsWidget({this.ingredients});

  Widget itemBuilder(BuildContext context, Ingredient ingredient) {
    return new Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(40)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey[500],
              offset: Offset(4.0, 4.0),
              blurRadius: 15.0,
              spreadRadius: 1.0)
        ],
      ),
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Align(
              child: FittedBox(
                child: Text(
                ingredient.name + " " + ingredient.amount,
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
                fit: BoxFit.cover,
              ),
              alignment: Alignment.center,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TableRow> rows = [];

    int rowNum = 3;
    int colNum =
        (ingredients.length ~/ 3) + ((ingredients.length % 3) > 0 ? 1 : 0);

    for (var i = 0; i < colNum; i++) {
      TableRow row = new TableRow(children: []);
      for (var j = i * rowNum; j < i * rowNum + rowNum; j++) {
        if (j < ingredients.length) {
          row.children.add(itemBuilder(context, ingredients[j]));
        } else {
          row.children.add(Container());
        }
      }
      rows.add(row);
    }

    return Table(
      children: rows,
    );
  }
}

class CalorieWidget extends StatelessWidget {
  final Nutrients calorie;

  CalorieWidget({this.calorie});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      width: 90,
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
