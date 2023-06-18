import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

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
  void reciveMessage(data) {
    print(data);
    if (data == null) return;
    setState(() {
      messages.add(Message(data: data['data'], id: data['id']));
    });
  }

  void sendMessage(String value) {
    Message message = Message(data: value, id: "from me");
    setState(() {
      messages.add(message);
    });
    socket!.emit('message', value);
  }

  @override
  void initState() {
    // TODO: implement initState
    // IO.Socket socket = IO.io('http://192.168.80.16:3000');
    // const url = 'http://192.168.80.16:3000';
    const url = 'https://socket.elitenutritiongroup.com';
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
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
              const Text(
                'Ingresa el mensaje:',
              ),
              TextField(
                controller: textEditingController,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  if (textEditingController.text.isEmpty) return;
                  sendMessage(textEditingController.text);
                  textEditingController.clear();
                },
                child: const Text('Enviar'),
              ),
              const SizedBox(
                height: 40,
              ),
              ...messages.map((e) {
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
                            e.data,
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
                            e.data,
                          ),
                        ),
                      );
              })
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home', arguments: '');
          },
          tooltip: 'to Home',
          child: const Icon(Icons.home),
        ));
  }
}

class Message {
  String data;
  String id;
  Message({required this.data, required this.id});
  toJson() {
    return {'message': data, 'id': id};
  }
}
