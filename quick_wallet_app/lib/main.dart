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
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const QuickWalletApp());
}

// App class
class QuickWalletApp extends StatelessWidget {
  const QuickWalletApp({super.key});

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
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Status of calculating geolocation
  bool _isGeolocationRunning = false;

  // List of all available cards.
  List<UserCard> _cards = [];

  // Token storage
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // filtered list of cards
  List<UserCard>? _searched;

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

  // Get geolocation and process it
  void _processGeolocation() async {
    if (!_isGeolocationRunning) {
      try {
        setState(() {
          _isGeolocationRunning = true;
        });
        LocationData location = await _determinePosition();
        var res = await Requests.get('$serverAddress/geo',
            queryParameters: {
              'lat': location.latitude,
              'long': location.longitude
            },
            port: serverPort,
            timeoutSeconds: 5);
      } finally {
        setState(() {
          _isGeolocationRunning = false;
        });
      }
    }
  }

  // Load cards from local storage
  void _loadCards() async {
    var prefs = await SharedPreferences.getInstance();
    var cards = prefs.getString('cards');
    if (cards != null) {
      Iterable l = jsonDecode(cards);
      _cards = List<UserCard>.from(l.map((e) => UserCard.fromJson(e)));
    }
    _cards.add(StubCard());
    if (_cards.length > 1) {
      _cards.insert(0, StubCard());
    }
  }

  // Safe cards to local storage
  void _dumpCards() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('cards', jsonEncode(_cards));
  }

  // on app init
  @override
  void initState() {
    super.initState();
    _loadCards();
    _processGeolocation();
  }

  // Render home page
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: 1,
        animationDuration: const Duration(microseconds: 250),
        // Main widget with top and bottom bar
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginView())),
            ),
          ),
          // tabs body
          body: TabBarView(children: <Widget>[
            // Search tab body
            Column(children: [
              // Grid
              Expanded(
                  child: GridView.count(
                childAspectRatio: cardWidth / cardHeight,
                crossAxisCount: 2,
                children: _searched ?? _cards,
              )),
              // Search box
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
            // Card Picker home page tab
            ScrollPicker(
              items: _cards,
              selectedItem: _cards[0],
              onSelectedTap: (card) {
                if (card.runtimeType == StubCard) {
                  DefaultTabController.of(context)?.animateTo(3);
                } else {
                  card.showBarcode(context);
                }
              },
              showDivider: false,
            ),
            // Add card tab
            Container(
              child: MobileScanner(
                onDetect: (barcode, args) {
                  print(barcode);
                  print(barcode.type);
                  print(barcode.format);
                  print(barcode.format.toString());
                },
              ),
            ),
          ]),
          // Debug button
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _cards.add(UserCard(nameOfShop: 'New card', cardNumber: '9780141026626'));
              });
            },
            tooltip: 'Get geolocation',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          // Bottom navigation bar
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
          ),
        ));
  }
}
