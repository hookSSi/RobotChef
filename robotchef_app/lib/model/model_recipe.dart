class Instruction {
  int proc_num;
  String desc;
  String image;

  Instruction.fromMap(Map<String, dynamic> map)
      : proc_num = map['proc_num'],
        desc = map['desc'],
        image = map['image'];

  @override
  String toString() => "Instruction<$proc_num : $desc>";
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

class Nutrients{
  String name;
  String weight;
  double percent;
  Nutrients({this.name, this.weight, this.percent});
}

class Recipe {
  String recipe_id;
  String title;
  String thumbnail;
  String sumry;
  String cooking_time;
  Nutrients calorie;
  List<Ingredient> ingredients;
  List<Instruction> instructions;
  bool like;

  Recipe.fromMap(Map<String, dynamic> map)
      : recipe_id = map['recipe_id'],
        title = map['title'],
        thumbnail = map['image'],
        sumry = map['sumry'],
        cooking_time = map['cooking_time'],
        calorie = Nutrients(name: 'calorie', weight: map['calorie'], percent: 0.5),
        ingredients = List<Ingredient>.from(map['ingredients']
            .map((item) => Ingredient.fromMap(item))
            .toList()),
        instructions = List<Instruction>.from(map['instructions']
            .map((item) => Instruction.fromMap(item))
            .toList()),
        like = false;

  @override
  String toString() => "Recipe<$recipe_id : $title> $ingredients , $instructions";
}
