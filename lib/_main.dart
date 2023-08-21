import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;
import 'package:sockets/utils.dart';
import 'pages/pages.dart';
import 'services/push_notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    // TODO: implement initState
    PushNotificationService.messageStream.listen((message) {
      print('MyApp: $message');

      final snackBar = SnackBar(content: Text(message));
      scaffoldMessengerKey.currentState!.showSnackBar(snackBar);

      navigatorKey.currentState!.pushNamed('/home', arguments: message);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/home': (_) => const HomeScreen(),
        '/details': (_) => const DetailsScreen(),
      },
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
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
  int _counter = 0;
  List<Message> messages = [];
  TextEditingController textEditingController = TextEditingController();
  IO.Socket? socket;
  int index = 0;
  String message = '';

  void reciveMessage(data) {
    print(data);
    if (data == null) return;
    setState(() {
      messages.add(Message(body: data['body'], id: data['from']));
    });
  }

  void sendMessage(String value) {
    Message message = Message(body: value, id: "from me");
    setState(() {
      messages.add(message);
    });
    socket!.emit('message', value);
  }

  @override
  void initState() {
    // TODO: implement initState
    // IO.Socket socket = IO.io('http://192.168.80.16:3000');
    const url = 'http://192.168.80.16:3000';
    // const url = 'https://socket.elitenutritiongroup.com';
    socket = IO.io(
        url,
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket!.connect();
    socket!.onConnect((_) {
      print('connect');
      socket!.emit('message', 'test');
    });
    socket!.on('orders:load', (data) {
      print(data);
    });
    socket!.on('message', reciveMessage);
    socket!.onDisconnect((_) => print('disconnect'));
    socket!.on('fromServer', (_) => print(_));
    socket!.on('connect_error', (data) => print(data));
    print('Conectado: ${socket!.connected}');

    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: SearchQuery())
                    .then((value) {
                  print(value);
                  if (value != null) {
                    message = value;
                    index = 1;

                    setState(() {});
                  }
                });
              },
              icon: const Icon(Icons.search))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: const Color.fromARGB(255, 77, 77, 77),
        selectedItemColor: Colors.deepPurple,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.find_in_page),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaions',
          ),
        ],
        currentIndex: index,
        onTap: (int index) => setState(() => this.index = index),
      ),
      body: pages(context),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/home', arguments: '');
      //   },
      //   tooltip: 'to Home',
      //   child: const Icon(Icons.home),
      // )
    );
  }

  Padding chatSocket(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final e = messages[index];
                return e.id == 'from me'
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            e.body,
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            e.body,
                          ),
                        ),
                      );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa el mensaje',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide:
                          BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          if (textEditingController.text.isEmpty) return;
                          sendMessage(textEditingController.text);
                          textEditingController.clear();
                        },
                        icon: const Icon(Icons.send)),
                    // labelText: 'Mensaje',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget pages(BuildContext context) {
    switch (index) {
      case 0:
        return chatSocket(context);
      case 1:
        return SearchScreen(message: message);
      case 2:
        return Center(
            child: ElevatedButton(
          onPressed: () => PushNotificationService.mostarNotificacion(),
          // ignore: prefer_const_constructors
          child: Text("presiona para activar notificación"),
        ));
      case 3:
        return BouncerScreen();
      case 4:
        return NotifcationScreen();
      default:
        return Container();
    }
  }
}

class Message {
  String body;
  String id;
  Message({required this.body, required this.id});
  toJson() {
    return {'body': body, 'id': id};
  }
}

class SearchScreen extends StatelessWidget {
  final String message;
  const SearchScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(message),
      ),
    );
  }
}

class SearchQuery extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Buscar';
  List<dynamic> lista = [];
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
        itemCount: lista.length,
        itemBuilder: (_, index) {
          return ListTile(
            onTap: () {
              Navigator.pop(context, lista[index]['volumeInfo']['title']);
            },
            title: Text(lista[index]['volumeInfo']['title']),
            subtitle: Text(lista[index]['volumeInfo']['authors'] != null
                ? lista[index]['volumeInfo']['authors'][0]
                : ''),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getSuggestionsByQuery(query);

    if (query.isEmpty) {
      return const Center(
        child: Icon(
          Icons.book,
          color: Colors.black38,
          size: 100,
        ),
      );
    }

    return StreamBuilder(
      builder: (_, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null) {
          return const Center(
            child: Text('No hay resultados'),
          );
        }

        final list = snapshot.data;
        lista = list;
        return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              return ListTile(
                onTap: () {
                  Navigator.pop(context, list[index]['volumeInfo']['title']);
                },
                title: Text(list[index]['volumeInfo']['title']),
                subtitle: Text(list[index]['volumeInfo']['authors'] != null
                    ? list[index]['volumeInfo']['authors'][0]
                    : ''),
              );
            });
      },
      stream: stream,
    );
  }

  final StreamController<dynamic> streamController =
      StreamController<dynamic>.broadcast();
  Stream<dynamic> get stream => streamController.stream;

  final debouncer =
      Debouncer<String>(duration: const Duration(milliseconds: 500));

  Future<void> queryStream(value) async {
    final values = await getMovies(value);
    if (values != null) {
      streamController.add(values);
    } else {
      streamController.add([]);
    }
  }

  void getSuggestionsByQuery(String search) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final values = await getMovies(value);
      if (values.toString().isNotEmpty) {
        streamController.add(values);
      } else {
        streamController.add([]);
      }
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = search;
    });

    Future.delayed(const Duration(milliseconds: 301))
        .then((_) => timer.cancel());
  }
}

getMovies(String query) async {
  if (query.isEmpty) return null;
  final url = 'https://www.googleapis.com/books/v1/volumes?q=$query';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw Exception('Error en la petición');
  final values = json.decode(response.body);

  return values['items'];
}

class BouncerScreen extends StatelessWidget {
  BouncerScreen({Key? key}) : super(key: key);

  TextEditingController textEditingController = TextEditingController();
  final ValueNotifier<String> _valueNotfier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              onChanged: (value) {
                debounce(() {
                  _valueNotfier.value = value;
                }, duration: const Duration(milliseconds: 500));
              },
              decoration: InputDecoration(
                hintText: 'Ingresa el mensaje',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                suffixIcon: ValueListenableBuilder<String>(
                    builder: (BuildContext context, value, Widget? child) {
                      return value.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                textEditingController.clear();
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _valueNotfier.value = "";
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : const SizedBox();
                    },
                    valueListenable: _valueNotfier),
                // labelText: 'Mensaje',
              ),
            ),
            Expanded(
                child: ValueListenableBuilder<String>(
              builder: (BuildContext context, value, Widget? child) {
                return FutureBuilder(
                  initialData: null,
                  future:
                      getMovies(textEditingController.text) as Future<dynamic>,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    final list = snapshot.data;
                    if (snapshot.data == null) {
                      return const Center(
                        child: Text('No hay resultados'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            final message = list[index]['volumeInfo']['title'];

                            final route = MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                                settings: RouteSettings(arguments: message));
                            Navigator.push(context, route);
                          },
                          title: Text(list[index]['volumeInfo']['title']),
                          subtitle: Text(
                              list[index]['volumeInfo']['authors'] != null
                                  ? list[index]['volumeInfo']['authors'][0]
                                  : ''),
                        );
                      },
                    );
                  },
                );
              },
              valueListenable: _valueNotfier,
            )),
          ],
        ),
      ),
    );
  }

  Timer? _debouncer;

  void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (_debouncer != null) {
      _debouncer!.cancel();
    }
    _debouncer = Timer(duration, callback);
  }
}

class NotifcationScreen extends StatelessWidget {
  NotifcationScreen({Key? key}) : super(key: key);
  final ValueNotifier<int> _valueNotfier = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: ValueListenableBuilder<int>(
            builder: (context, value, child) {
              return Text('El valor es $value');
            },
            valueListenable: _valueNotfier,
          ),
        ),
        floatingActionButton: NotificationListener<CounterNotification>(
            onNotification: (notification) {
              _valueNotfier.value = notification.value;
              return true;
            },
            child: CounterButton()));
  }
}

class CounterButton extends StatelessWidget {
  CounterButton({
    super.key,
  });
  final _counter = Counter();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final value = _counter.increment();
        CounterNotification(value).dispatch(context);
      },
      child: const Icon(Icons.plus_one),
    );
  }
}

class CounterNotification extends Notification {
  final int value;

  CounterNotification(this.value);
}

class Counter {
  int _value = 0;
  Counter([this._value = 0]);
  int increment() {
    _value++;
    return _value;
  }

  get value => _value;
  int decrement() {
    _value--;
    return _value;
  }
}
