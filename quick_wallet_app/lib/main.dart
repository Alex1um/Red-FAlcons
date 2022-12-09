import 'login.dart';
import 'package:flutter/material.dart';
import 'card.dart';
import 'card_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'card_adder.dart';
import 'user_session.dart';
import 'shops.dart';

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
      // themeMode: ThemeMode.system,
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      //   primarySwatch: Colors.deepOrange,
      // ),
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // primaryColor: Colors.teal[400],
        brightness: Brightness.dark,
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

  bool _isAddingCard = false;

  // filtered list of cards
  List<UserCard>? _searched;

  late UserSession _session;

  void _addCardDialog(barcode, args) async {
    if (!_isAddingCard) {
      _isAddingCard = true;
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CardAdder(
                    cardNumber: barcode.rawValue,
                    barcodeType: UserCard.convertBarcodeFormat(barcode.format),
                    session: _session,
                  )));
      setState(() {});
      _isAddingCard = false;
    }
  }

  // on app init
  @override
  void initState() {
    super.initState();
    _session = UserSession();
    _session.init();
  }

  // Render home page
  @override
  Widget build(BuildContext context) {
    var stub1 = <UserCard>[StubCard()];
    var stub2 = <UserCard>[StubCard()];
    // var card_list = <UserCard>[StubCard()] + _session.cards;
    // if (_session.cards.isNotEmpty) {
    //   card_list += <UserCard>[StubCard()];
    // }
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
                          builder: (context) => LoginView(session: _session)))
                  .then((value) => setState(() {})),
            ),
          ),
          // tabs body
          body: Builder(
              builder: (context) => TabBarView(children: <Widget>[
                    // Search tab body
                    Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/bg-4.jpg'),
                                fit: BoxFit.cover)),
                        child: Column(children: [
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
                                          .where((UserCard element) => element
                                              .shop.name
                                              .toLowerCase()
                                              .contains(value.toLowerCase()))
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
                        ])),
                    // Card Picker home page tab
                    Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/bg-1.JPG'),
                                fit: BoxFit.cover)),
                        child: ScrollPicker(
                          items: _session.cards.isEmpty ? stub1 : stub1 + _session.cards + stub2,
                          selectedItem: _session.cards.isEmpty ? stub1[0] : _session.cards[0],
                          onSelectedTap: (card) {
                            if (card.runtimeType == StubCard) {
                              DefaultTabController.of(context)?.animateTo(2);
                            } else {
                              card.showBarcode(context, _session);
                            }
                          },
                          showDivider: false,
                        )),
                    // Add card tab
                    Stack(
                      children: <Widget>[
                        MobileScanner(onDetect: _addCardDialog),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 40, horizontal: 25),
                                child: ElevatedButton(
                                    // style: ElevatedButton.styleFrom(
                                    //     minimumSize: const Size.fromHeight(50)),
                                    onPressed: () {
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
                                    },
                                    child: const Text(
                                      "Add card Manually",
                                      style: TextStyle(fontSize: 18.0),
                                    ))))
                      ],
                    ),
                  ])),
          // Bottom navigation bar
          bottomNavigationBar: TabBar(
            tabs: const [
              Tab(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  text: 'Cards'),
              Tab(icon: Icon(Icons.approval), text: 'Suggested'),
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
