import 'login.dart';
import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'package:location/location.dart';
import 'card.dart';
import 'config.dart';
import 'card_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'card_adder.dart';
import 'user_session.dart';

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
  // List<UserCard> _cards = [];

  // Token storage
  // final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  MobileScannerController _camController = MobileScannerController();
  bool _isAddingCard = false;

  // filtered list of cards
  List<UserCard>? _searched;

  late UserSession _session;

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
        if (location.latitude != null && location.longitude != null) {
          var nearest = await _session
              .sendGeo(long: location.longitude!, lat: location.latitude!);
          // TODO: process geolocation
          // _session.cards.sort((a, b) => nearest.indexOf());
        }
      } finally {
        setState(() {
          _isGeolocationRunning = false;
        });
      }
    }
  }

  // on app init
  @override
  void initState() {
    super.initState();
    _session = UserSession();
    _session.init();

    _processGeolocation();
  }

  // Render home page
  @override
  Widget build(BuildContext context) {
    var card_list = <UserCard>[StubCard()] + _session.cards;
    if (_session.cards.isNotEmpty) {
      card_list += <UserCard>[StubCard()];
    }
    return DefaultTabController(
        length: 3,
        initialIndex: 1,
        animationDuration: const Duration(microseconds: 250),
        // Main widget with top and bottom bar
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginView(session: _session))),
            ),
          ),
          // tabs body
          body: Builder(
              builder: (context) => TabBarView(children: <Widget>[
                    // Search tab body
                    Column(children: [
                      // Grid
                      Expanded(
                          child: GridView.count(
                        childAspectRatio: cardWidth / cardHeight,
                        crossAxisCount: 2,
                        children: _searched ?? _session.cards,
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
                                  _searched = _session.cards
                                      .where((UserCard element) =>
                                          element.shop.name.contains(value))
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
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(25.0)))),
                          ))
                    ]),
                    // Card Picker home page tab
                    ScrollPicker(
                      items: card_list,
                      selectedItem: card_list[0],
                      onSelectedTap: (card) {
                        if (card.runtimeType == StubCard) {
                          DefaultTabController.of(context)?.animateTo(2);
                        } else {
                          card.showBarcode(context);
                        }
                      },
                      showDivider: false,
                    ),
                    // Add card tab
                    Stack(
                      children: <Widget>[
                        MobileScanner(
                          onDetect: (barcode, args) {
                            // if (!_isAddingCard) {
                            // _isAddingCard = true;
                            // deactivate();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CardAdder(
                                          cardNumber: barcode.rawValue,
                                          barcodeType:
                                              UserCard.convertBarcodeFormat(
                                                  barcode.format),
                                          session: _session,
                                        ))).then((value) {
                              _isAddingCard = false;
                              // activate();
                              setState(() {
                                _session.addCard(value);
                              });
                            });
                            // }
                          },
                        ),
                        ElevatedButton(onPressed: () {

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CardAdder(
                                    session: _session,
                                  ))).then((value) {
                            _isAddingCard = false;
                            // activate();
                            setState(() {
                              _session.addCard(value);
                            });
                          });

                        }, child: Text("Add card Manually"))
                      ],
                    ),
                  ])),
          // Debug button
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     setState(() {
          //       // _session.addCard(UserCard(
          //       //     nameOfShop: 'New card', cardNumber: '9780141026626'));
          //       _processGeolocation();
          //     });
          //   },
          //   tooltip: 'Get geolocation',
          //   child: const Icon(Icons.add),
          // ),
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
