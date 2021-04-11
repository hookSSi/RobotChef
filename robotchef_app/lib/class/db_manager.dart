import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'app_constants.dart';

class DBManager {
  static DBManager instance;
  Database database = null;

  static DBManager get Instance {
    if (instance == null) {
      instance = DBManager();
    }
    return instance;
  }

  Future<Database> get DB async {
    if (database == null) {
      database = await Init();
    }

    return database;
  }

  Init() async {
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

  AddData(String tableName, int recipe_id) async {
    final db = await DB;
    var res = await db.insert(tableName, {"recipe_id" : recipe_id} );
    return res;
  }

  GetData(String tableName, int recipe_id) async {
    final db = await DB;
    var res = await db.query(tableName, where: "recipe_id = ?", whereArgs: [recipe_id]);
    return res.isNotEmpty ? true : false;
  }

  DeleteData(String tableName, int recipe_id) async {
    final db = await DB;
    db.delete(tableName, where: 'recipe_id = ?', whereArgs: [recipe_id]);
    var res = await GetData(tableName, recipe_id);

    return res == null ? true : false;
  }

  GetAllData(String tableName) async {
    final db = await DB;
    var res = await db.query(tableName);
    List<dynamic> recipe_list = res.isNotEmpty ? res.map((e) => e["recipe_id"]).toList() :  [];
    return recipe_list;
  }
}
