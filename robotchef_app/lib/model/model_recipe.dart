import 'package:flutter_app/class/app_constants.dart';
import 'package:flutter_app/class/db_manager.dart';

class Instruction {
  int procNum;
  String desc;
  String image;

  Instruction.fromMap(Map<String, dynamic> map)
      : procNum = map['proc_num'],
        desc = map['desc'],
        image = map['image'];

  @override
  String toString() => "Instruction<$procNum : $desc>";
}

class Ingredient {
  String name;
  String amount;

  Ingredient.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        amount = map['amount'];

  @override
  String toString() => "Ingredient<$name : $amount>";
}

class Nutrients {
  String name;
  String weight;
  double percent;

  Nutrients({this.name, this.weight, this.percent});
}

double calcPercent(weight, max){
  var regex = new RegExp(r'[0-9]*\.?[0-9]+');
  var match = regex.firstMatch(weight);
  double res = double.tryParse(match.group(0)) / max;

  return res;
}

class Recipe {
  String recipeId;
  String title;
  String thumbnail;
  String sumry;
  String cookingTime;
  Nutrients calorie;
  List<Ingredient> ingredients;
  List<Instruction> instructions;

  Recipe.fromMap(Map<String, dynamic> map)
      : recipeId = map['recipe_id'],
        title = map['title'],
        thumbnail = map['image'],
        sumry = map['sumry'],
        cookingTime = map['cooking_time'],
        // 칼로리 하루 평균 성인 남자 기준 2700
        calorie =
            Nutrients(name: 'calorie', weight: map['calorie'], percent: calcPercent(map['calorie'], 2700)),
        ingredients = List<Ingredient>.from(map['ingredients']
            .map((item) => Ingredient.fromMap(item))
            .toList()),
        instructions = List<Instruction>.from(map['instructions']
            .map((item) => Instruction.fromMap(item))
            .toList());

    Future<bool> getBookmark() async{
    return await DBManager.getInstance.getData(AppConstants.bookmarkDoc, int.tryParse(recipeId));
  }

  @override
  String toString() =>
      "Recipe<$recipeId : $title> $ingredients , $instructions";
}
