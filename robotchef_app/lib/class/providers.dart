import 'package:flutter_app/class/recipe_search.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(
    create: (context) => RecipeSearcher(),
    lazy: false,
  )
];
