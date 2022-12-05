import 'login.dart';
import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'card.dart';
import 'dart:convert';
import 'config.dart';
import 'card_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Wallet app',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _widgetIndex = 1;
  String _geolocation = 'zero';
  bool _isGeolocationRunning = false;
  List<UserCard> _cards = [];
  UserCard? _selected_card;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<UserCard>? _searched;

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
    return DefaultTabController(
        length: 3,
        initialIndex: 1,
        animationDuration: const Duration(microseconds: 250),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginView())),
            ),
          ),
          body: TabBarView(children: <Widget>[
            Column(children: [
              Expanded(
                  child: GridView.count(
                childAspectRatio: cardWidth / cardHeight,
                crossAxisCount: 2,
                children: _searched ?? _cards,
              )),
              Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _searched = null;
                        } else {
                          _searched = _cards
                              .where((UserCard element) =>
                          element.nameOfShop.contains(value))
                              .toList();
                        }
                      });
                    },
                    // controller: editingController,
                    decoration: const InputDecoration(
                        labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ))
            ]),
            ScrollPicker(
              items: _cards,
              selectedItem: _cards[0],
              onChanged: (card) {
                print("new item: $card");
              },
              onSelectedTap: (card) {
                print('old item: $card');
              },
              showDivider: false,
            ),
            Container(),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _cards.add(const UserCard(
                    nameOfShop: 'nameOfShop', cardNumber: 'cardNumber'));
              });
            },
            tooltip: 'Get geolocation',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.search), text: 'Search'),
              Tab(icon: Icon(Icons.filter_list), text: 'Suggested'),
              Tab(icon: Icon(Icons.add_card), text: 'Add new'),
            ],
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicator: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 3)),
            ),
            unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
            labelColor: Theme.of(context).colorScheme.primary,
            onTap: _onTabTap,
          ),
        ));
  }
}
