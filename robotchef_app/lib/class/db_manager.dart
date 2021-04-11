import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'app_constants.dart';

class DBManager {
  static DBManager instance;
  Database database;

  static DBManager get getInstance {
    if (instance == null) {
      instance = DBManager();
    }
    return instance;
  }

  Future<Database> get getDB async {
    if (database == null) {
      database = await init();
    }

    return database;
  }

  init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'BookmarkDB.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''CREATE TABLE ${AppConstants.bookmarkDoc} 
                              (recipe_id INTEGER PRIMARY KEY)''');
      },
    );
  }

  addData(String tableName, int recipeId) async {
    final db = await getDB;
    var res = await db.insert(tableName, {"recipe_id" : recipeId} );
    return res;
  }

  getData(String tableName, int recipeId) async {
    final db = await getDB;
    var res = await db.query(tableName, where: "recipe_id = ?", whereArgs: [recipeId]);
    return res.isNotEmpty ? true : false;
  }

  deleteData(String tableName, int recipeId) async {
    final db = await getDB;
    db.delete(tableName, where: 'recipe_id = ?', whereArgs: [recipeId]);
    var res = await getData(tableName, recipeId);

    return res == null ? true : false;
  }

  getAllData(String tableName) async {
    final db = await getDB;
    var res = await db.query(tableName);
    List<dynamic> recipeList = res.isNotEmpty ? res.map((e) => e["recipe_id"]).toList() :  [];
    return recipeList;
  }
}
