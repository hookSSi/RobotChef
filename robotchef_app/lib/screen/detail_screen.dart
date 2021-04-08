import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/class/app_constants.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:flutter_app/widget/circle_indicator.dart';
import 'package:flutter_app/class/auth_state.dart';
import 'package:provider/provider.dart';

// 레시피의 상세 화면을 만드는 스크린
class DetailScreen extends StatefulWidget {
  // final Recipe recipe;
  // DetailScreen({this.recipe});
  final Recipe recipe;

  DetailScreen({this.recipe});

  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool like = false;

  Future<bool> createBookmarkDoc(user_email, recipe_id) async {
    try {
      AuthState state = Provider.of<AuthState>(context, listen: false);

      var result = await state.database.createDocument(
          collectionId: AppWriteConstants.bookmarkDocId,
          data: {"email": user_email, "recipe_id": recipe_id},
          read: ["*"],
          write: ["*"]);
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> removeBookmarkDoc(documentId) async {
    try {
      AuthState state = Provider.of<AuthState>(context, listen: false);

      var result = await state.database.deleteDocument(
          collectionId: AppWriteConstants.bookmarkDocId,
          documentId: documentId);
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> addBookmark() async {
    try {
      AuthState state = Provider.of<AuthState>(context, listen: false);

      String user_email = state.user.email;
      String recipe_id = widget.recipe.recipe_id;

      var result = await state.database.listDocuments(
          collectionId: AppWriteConstants.bookmarkDocId,
          filters: ['email=$user_email', 'recipe_id=$recipe_id']);

      dynamic jsonObj = jsonDecode(result.toString());
      if (jsonObj['sum'] == 0) {
        createBookmarkDoc(user_email, recipe_id);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> removeBookmark() async {
    try {
      AuthState state = Provider.of<AuthState>(context, listen: false);

      String user_email = state.user.email;
      String recipe_id = widget.recipe.recipe_id;

      var result = await state.database.listDocuments(
          collectionId: AppWriteConstants.bookmarkDocId,
          filters: ['email=$user_email', 'recipe_id=$recipe_id']);

      dynamic jsonObj = jsonDecode(result.toString());
      if (jsonObj['sum'] != 0) {
        removeBookmarkDoc(jsonObj['documents'][0]['\$id']);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<bool> getBookmark() async {
    try {
      AuthState state = Provider.of<AuthState>(context, listen: false);

      String user_email = state.user.email;
      String recipe_id = widget.recipe.recipe_id;

      var result = await state.database.listDocuments(
          collectionId: AppWriteConstants.bookmarkDocId,
          filters: ['email=$user_email', 'recipe_id=$recipe_id']);

      dynamic jsonObj = jsonDecode(result.toString());
      if (jsonObj['sum'] != 0) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    Future<bool> result = getBookmark();
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
                  Row(
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
                                Future<bool> isEnd = removeBookmark();
                                isEnd.then((value) => setState(() {
                                      like = false;
                                    }));
                              })
                          : IconButton(
                              color: Color(0xFFFFFFFF),
                              icon: Icon(Icons.star_border),
                              onPressed: () {
                                Future<bool> isEnd = addBookmark();
                                isEnd.then((value) => setState(() {
                                      like = true;
                                    }));
                              })
                    ],
                  ),
                  Divider(),
                  Text('영양',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  CalorieWidget(
                    calorie: widget.recipe.calorie,
                  ),
                  Divider(),
                  Text('필요한 재료들',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  IngredientsWidget(
                    ingredients: widget.recipe.ingredients,
                  ),
                  Divider(),
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
