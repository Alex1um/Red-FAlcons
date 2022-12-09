import 'package:http/src/response.dart';

import 'card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:requests/requests.dart';
import 'config.dart';
import 'shops.dart';
import 'package:location/location.dart';

// Enable needed services and get geolocation
Future<LocationData> _determinePosition() async {
  var location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return Future.error('Something went wrong with enabling service');
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return Future.error('Can\'t get location permission');
    }
  }

  return await location.getLocation();
}

class AuthError implements Exception {
  String? loginMsg;
  String? passMsg;

  AuthError({this.loginMsg, this.passMsg});
}

class UserSession {
  List<UserCard> cards = [];
  List<Shop> shops = [];

  UserSession();

  OnlineSession _onlineSession = OnlineSession();

  String? get name => _onlineSession.name;

  init() async {
    var prefs = await SharedPreferences.getInstance();
    // prefs.remove('cards');
    // prefs.remove('shops');

    var shops = prefs.getString('shops');
    if (shops != null) {
      Iterable l = jsonDecode(shops);
      this.shops = List<Shop>.from(l.map((e) => Shop.fromJson(e)));
    }
    await syncStoreData();

    var cards = prefs.getString('cards');
    if (cards != null) {
      Iterable l = jsonDecode(cards);
      this.cards = List<UserCard>.from(l.map((e) => UserCard.fromJson(e)));
    }

    try {
      await _onlineSession.load();
      _onlineSession.name = await prefs.getString('login');
    } catch (e) {
      print(e);
    }
    await syncCardData();
  }

  syncCardData() async {
    if (isLoggedIn()) {
      // var cards = <UserCard>[];
      Iterable l = await this._onlineSession.getCards();
      this.cards = List<UserCard>.from(l.map((e) => UserCard.fromResponse(e, this)));
      await saveCards();
      LocationData location = await _determinePosition();
      if (location.latitude != null && location.longitude != null) {
        await _onlineSession.sendGeo(long: location.longitude!, lat: location.latitude!);
      }
    }
  }

  syncStoreData() async {
    var res = await Requests.get('$serverAddress/stores',
    );
    if (res.success) {
      Iterable l = jsonDecode(res.body);
      this.shops = List<Shop>.from(l.map((e) => Shop.fromJson(e)));
    }
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('shops', jsonEncode(shops));
  }

  saveCards() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('cards', jsonEncode(cards));
    if (isLoggedIn()) {
      await prefs.setString('login', _onlineSession.name!);
    }
    await _onlineSession.save();
  }

  addCard(UserCard newCard) async {
    if (isLoggedIn()) {
      newCard = UserCard.fromResponse(await _onlineSession.uploadCard(newCard), this);
    }
    cards.add(newCard);
    await saveCards();
  }

  login({required String login, required String password}) async {
    await _onlineSession.login(login: login, password: password);
    _onlineSession.name = login;
    await saveCards();
    await syncStoreData();
  }


  register({required String login, required String password}) async {
    await _onlineSession.register(login: login, password: password);
  }

  bool isLoggedIn() {
    return _onlineSession.name != null;
    // return _onlineSession.isLoggedIn();
  }

  signOut() async {
    _onlineSession.name = null;
    await _onlineSession.signOut();
  }

  void procGeo({required double lat, required double long}) async {
    var res = await _onlineSession.sendGeo(lat: lat, long: long)
    if (res.success) {
      Iterable l = jsonDecode(res.body);
      this.cards = List<UserCard>.from(l.map((e) => UserCard.fromJson(e)));
      // return List<int>.from(l.map((e) => e['store_id']));

    }
  }

}

class OnlineSession {
  String? token;
  String? token_type;
  String? name;

  OnlineSession();

  uploadCard(UserCard card) async {
    var creds = {'store_id': card.shop.id, 'code': card.cardNumber, 'code_type': card.barcode.index};
    var res = await Requests.post(
        '$serverAddress/cards/',
        json: creds,
        port: serverPort,
        timeoutSeconds: 30,
        headers: {'Authorization': '${token_type} ${token}'},
    );
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getCards() async {
    var res = await Requests.get(
      '$serverAddress/cards/',
      port: serverPort,
      timeoutSeconds: 30,
      headers: {'Authorization': '${token_type} ${token}'},
    );
    return jsonDecode(res.body);
  }

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
        json: creds, port: serverPort, timeoutSeconds: 30);
    print(res.body);
    Map<String, dynamic> data = jsonDecode(res.body);
    if (!res.success) {
      String msg = data.containsKey('detail') ? data['detail']! : "Unknown error";
      throw AuthError(
          loginMsg: msg, passMsg: msg.contains('Username') ? null : msg);
    }

  }

  login({required String login, required String password}) async {
    var creds = {'username': login, 'password': password};
    var res = await Requests.post('$serverAddress/auth/login',
        body: creds, port: serverPort, timeoutSeconds: 30);
    Map<String, dynamic> data = jsonDecode(res.body);
    print(data);
    if (!res.success) {
      String msg =
          data.containsKey('detail') ? data['detail']! : "Unknown error";
      throw AuthError(loginMsg: msg, passMsg: msg);
    }
    token = data['access_token']!;
    token_type = data['token_type']!;
    // {user_id: 1, exp: 1670434534}
  }

  signOut() async {
    var secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'token_type');
    await secureStorage.delete(key: 'login');
    token = null;
    token_type = null;
  }

  Future<Response> sendGeo({required double lat, required double long}) async {
    var creds = {'latitude': lat, 'longitude': long};
    return await Requests.get('$serverAddress/cards/geo',
        queryParameters: creds,
        port: serverPort,
        timeoutSeconds: 30,
        headers: {'Authorization': '${token_type} ${token}'});
  }
}
