import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecipeSearcher with ChangeNotifier {
  Map<String, List<String>> _tagDict;

  RecipeSearcher(){
    _tagDict = {"ingredients" : []};
  }

  void clear(){
    _tagDict["ingredients"].clear();
    notifyListeners();
  }

  void addIngredients(List<String> ingredients){
    print(ingredients);
    _tagDict["ingredients"] = ingredients;
    notifyListeners();
  }

  String getSearchText(){
    if(_tagDict["ingredients"].length > 0){
      String searchText = "ingredients:" + _tagDict["ingredients"].join(',');
      return searchText;
    }else{
      return "";
    }
  }
}
