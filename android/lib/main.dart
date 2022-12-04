import 'login.dart';
import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'card.dart';
import 'dart:convert';
import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
      ),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _widgetIndex = 1;
  String _geolocation = 'zero';
  bool _isGeolocationRunning = false;
  List<UserCard> _cards = [];
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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

  void _processGeolocation() async {
    if (!_isGeolocationRunning) {
      try {
        setState(() {
          _isGeolocationRunning = true;
        });
        LocationData location = await _determinePosition();
        setState(() {
          _geolocation = location.toString();
        });
        print(location);
        var res = await Requests.get('$serverAddress/geo',
            queryParameters: {
              'lat': location.latitude,
              'long': location.longitude
            },
            port: serverPort,
            timeoutSeconds: 5);
        print(res.body);
      } finally {
        setState(() {
          _isGeolocationRunning = false;
        });
      }
    }
  }

  void _onTabTap(int index) {
    setState(() {
      _widgetIndex = index;
    });
  }

  void _loadCards() async {
    var prefs = await SharedPreferences.getInstance();
    var cards = prefs.getString('cards');
    if (cards != null) {
      Iterable l = jsonDecode(cards);
      _cards = List<UserCard>.from(l.map((e) => UserCard.fromJson(e)));
    }
  }

  void _dumpCards() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('cards', jsonEncode(_cards));
  }

  @override
  void initState() {
    _loadCards();
    _processGeolocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginView())),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const UserCard(
              nameOfShop: '123',
              cardNumber: 'asd',
            ),
            const Text(
              'Your geolocation is:',
            ),
            Text(_geolocation),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _processGeolocation,
        tooltip: 'Get geolocation',
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.filter_list), label: 'Suggested'),
          BottomNavigationBarItem(icon: Icon(Icons.add_card), label: 'Add new'),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        currentIndex: _widgetIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
