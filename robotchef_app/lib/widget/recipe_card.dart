import 'package:flutter/material.dart';
import 'package:flutter_app/model/model_recipe.dart';
import 'package:flutter_app/class/app_constants.dart';
import 'package:flutter_app/class/db_manager.dart';

// 레시피의 상세 화면을 만드는 스크린
class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final Function onTapCard;

  RecipeCard({@required this.recipe, @required this.onTapCard});

  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool like = false;

  Future<bool> bookmark(int recipeId) async {
    if (!like) {
      await DBManager.getInstance
          .addData(AppConstants.bookmarkDoc, recipeId);
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
    RawMaterialButton _buildFavoriteButton() {
      return RawMaterialButton(
        constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
        onPressed: () {
          int recipeId = int.tryParse(widget.recipe.recipeId);
          Future<bool> isEnd = bookmark(recipeId);
          isEnd.then((value) => setState(() {
                like = value;
              }));
        },
        child: Icon(
          like ? Icons.favorite : Icons.favorite_border,
          color: Color(0xFFFD0016)
        ),

        elevation: 2.0,
        fillColor: Colors.white,
        shape: CircleBorder(),
      );
    }

    Padding _buildTitleSection() {
      return Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          // Default value for crossAxisAlignment is CrossAxisAlignment.center.
          // We want to align title and description of recipes left:
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.recipe.title,
            ),
            Text('해쉬태그', style: Theme.of(context).textTheme.caption,),
            // Empty space:
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.timer, size: 20.0),
                SizedBox(width: 5.0),
                Text(
                  widget.recipe.cookingTime,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTapCard,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // We overlap the image and the button by
              // creating a Stack object:
              Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: Image.network(
                      widget.recipe.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    child: _buildFavoriteButton(),
                    top: 2.0,
                    right: 2.0,
                  ),
                ],
              ),
              _buildTitleSection(),
            ],
          ),
        ),
      ),
    );
  }
}
