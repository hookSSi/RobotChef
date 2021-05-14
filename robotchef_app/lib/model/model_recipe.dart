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

class IngredientsGroup{
  String name;
  List<Ingredient> ingredients;
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
  String hash_tag;
  Nutrients info_eng; /// 열량
  Nutrients info_car; /// 탄수화물
  Nutrients info_pro; /// 단백질
  Nutrients info_fat; /// 지방
  Nutrients info_na; /// 나트륨
  List<Ingredient> ingredients;
  List<Instruction> instructions;

  Recipe.fromMap(Map<String, dynamic> map)
      : recipeId = map['recipe_id'],
        title = map['title'],
        thumbnail = map['image'],
        sumry = map['sumry'],
        cookingTime = map['cooking_time'],
        // 칼로리 하루 평균 성인 남자 기준 2700
        info_eng =
            Nutrients(name: '칼로리', weight: map['calorie'], percent: calcPercent(map['calorie'], 2700)),
        info_car =
            Nutrients(name: '탄수화물', weight: "100", percent: calcPercent("50", 100)),
        info_pro =
            Nutrients(name: '단백질', weight: "100", percent: calcPercent("50", 100)),
        info_fat =
            Nutrients(name: '지방', weight: "100", percent: calcPercent("50", 100)),
        info_na =
            Nutrients(name: '나트륨', weight: "100", percent: calcPercent("50", 100)),
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
