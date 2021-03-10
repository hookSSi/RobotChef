import 'package:flutter_app/class/auth_state.dart';
import 'package:flutter_app/class/recipe_serach.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(
    create: (context) => AuthState(),
    lazy: false,
  ),
  ChangeNotifierProvider(
    create: (context) => RecipeSearcher(),
    lazy: false,
  )
];
