import 'card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:requests/requests.dart';
import 'config.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthError implements Exception {
  String? loginMsg;
  String? passMsg;
  AuthError({this.loginMsg, this.passMsg});
}

class UserSession {

  List<UserCard> cards = [];

  UserSession();
  OnlineSession onlineSession = OnlineSession();

  init() async {
    var prefs = await SharedPreferences.getInstance();
    var cards = prefs.getString('cards');
    if (cards != null) {
      Iterable l = jsonDecode(cards);
      this.cards = List<UserCard>.from(l.map((e) => UserCard.fromJson(e)));
    }
    try {
      await onlineSession.load();
    }
    catch(e) {
      print(e);
    }
    await syncStoreData();
  }

  syncStoreData() async {
    if (onlineSession.isLoggedIn()) {
      var res = await Requests.get('$serverAddress/stores',
      headers: {'Authorization': '${onlineSession.token_type} ${onlineSession.token}'});
      print('--------------');
      print(res.body);
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setString('cards', jsonEncode(cards));
  }

  addCard(UserCard newCard) {
    cards.add(newCard);
  }

}

class OnlineSession {
  String? token;
  String? token_type;

  OnlineSession();

  load() async {
    var secureStorage = FlutterSecureStorage();
    token = await secureStorage.read(key: 'token');
    token_type = await secureStorage.read(key: 'token_type');
    if (!isLoggedIn()) {
      throw "No stored session found";
    }
  }

  bool isLoggedIn() {
    return token != null;
  }

  save() async {
    if (isLoggedIn()) {
      var secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'token', value: token);
      await secureStorage.write(key: 'token_type', value: token_type);
    }
  }

  register({required String login, required String password}) async {
    var creds = {'username': login, 'password': password};
    var res = await Requests.post('$serverAddress/auth/register',
        json: creds,
        port: serverPort,
        timeoutSeconds: 30);
    Map<String, String> data = jsonDecode(res.body);
    if (!res.success) {
      String msg = data.containsKey('detail') ? data['detail']! : "Unknown error";
      throw AuthError(loginMsg: msg, passMsg: msg.contains('Username') ? null : msg);
    }
  }

  login({required String login, required String password}) async {
    var creds = {'username': login, 'password': password};
    var res = await Requests.post('$serverAddress/auth/login',
        body: creds,
        port: serverPort,
        timeoutSeconds: 30);
    print(res.body);
    Map<String, dynamic> data = jsonDecode(res.body);
    print(data);
    if (!res.success) {
      String msg = data.containsKey('detail') ? data['detail']! : "Unknown error";
      throw AuthError(loginMsg: msg, passMsg: msg);
    }
    token = data['access_token']!;
    token_type = data['token_type']!;
    await save();
    // {user_id: 1, exp: 1670434534}
  }

  signOut() async {
    var secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'token_type');
    token = null;
    token_type = null;
  }


}