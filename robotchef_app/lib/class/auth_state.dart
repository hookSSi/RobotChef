import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_app/class/app_constants.dart';
import 'package:flutter_app/model/model_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthState extends ChangeNotifier{
  Client client = Client();

  FlutterSecureStorage secureStorage = FlutterSecureStorage();
  Account account;
  bool _isLoggedIn;
  User _user;

  Database database;

  String _error;

  bool get isLoggedIn => _isLoggedIn;
  User get user => _user;
  String get error => _error;

  AuthState(){
    _init();
  }

  _init(){
    _isLoggedIn = false;
    _user = null;
    client.setEndpoint(AppWriteConstants.endpoint)
        .setProject(AppWriteConstants.projectId);
    account = Account(client);
    database = Database(client);
  }

  _checkIsLoggedIn() async {
    try{
      _user = await _getAccount();
      _isLoggedIn = true;
      notifyListeners();
    }
    catch(error) {
      print(error.message);
    }
  }

  Future<User> _getAccount() async{
    try{
      Response<dynamic> res = await account.get();
      if(res.statusCode == 200){
        return User.fromJson(res.data);
      } else{
        return null;
      }
    } catch(error){
      throw error;
    }
  }

  createAccount(String username, String email, String password) async {
    try{
      var result = await account.create(name: username, email: email, password: password);
      print(result);
      return result;
    }
    catch(error){
      print(error.message);
      return null;
    }
  }

  logout() async {
    try{
      await secureStorage.delete(key: "email");
      await secureStorage.delete(key: "password");
    }
    catch(error){
      print(error.message);
    }

    try{
      Response res = await account.deleteSession(sessionId: 'current');
      print(res.statusCode);
      _isLoggedIn = false;
      _user = null;
    } catch(error){
      _error = error.message;
      notifyListeners();
    }
  }

  saveLoginInfo(String email, String password) async {
    await secureStorage.write(key: "email", value: email);
    await secureStorage.write(key: "password", value: password);
  }

  login(String email, String password) async {
    try{
      var result = await account.createSession(email: email, password: password);
      if(result.statusCode == 201){
        _isLoggedIn = true;
        _user = await _getAccount();
      }
      notifyListeners();
      print(result);
    }
    catch(error){
      _error = error.message;
      print(error.message);
    }
  }
}