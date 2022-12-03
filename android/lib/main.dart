import 'package:android/login.dart';
import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'dart:developer' as developer;

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
  int _widget_index = 1;
  String _geolocation = 'zero';
  bool _geolocation_running = false;

  Future<LocationData> _determinePosition() async {
    Location location = new Location();

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

  void _process_geolocation() async {
    if (!_geolocation_running) {
      try {
        setState(() {
          _geolocation_running = true;
        });
        LocationData location = await _determinePosition();
        print(location);
        var res = await Requests.get('http://192.168.50.50/geo',
            queryParameters: {
              'lat': location.latitude,
              'long': location.longitude
            }, port: 8000);
        print(res.body);
      } finally {
        setState(() {
          _geolocation_running = false;
        });
      }
    }
  }

  void _onTabTap(int index) {
    setState(() {
      _widget_index = index;
    });
  }

  @override
  void initState() {
    _process_geolocation();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        // title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginView())),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your geolocation is:',
            ),
            Text(_geolocation),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _process_geolocation,
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
        currentIndex: _widget_index,
        onTap: _onTabTap,
      ),
    );
  }
}

class card extends StatelessWidget {
  const card({Key? key, required this.name_of_shop, required this.card_number}) : super(key: key);
  final String name_of_shop;
  final String card_number;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 150,
      width: 238,
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage('https://yandex.ru/images/search?text=mastercard%20picture&from=tabbar&p=1&pos=37&rpt=simage&img_url=http%3A%2F%2Fmemberscommunitycu.org%2Fwp-content%2Fuploads%2F2018%2F06%2FMastercard-01.png&lr=65')
        ),
        border: Border.all(
          color: Colors.grey,
          width: 5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Text(name_of_shop, style: TextStyle(color: Colors.deepOrange)),
          Text(card_number, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
