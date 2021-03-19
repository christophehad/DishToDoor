import 'package:dishtodoor/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dishtodoor/screens/page_navigator_eater.dart';
import 'package:dishtodoor/screens/page_navigator_cook.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dishtodoor/config/config.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class App extends StatefulWidget {
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      somethingWentWrong(context);
      print("Firebase initialization failed");
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return loading();
    }

    return MaterialApp(
        title: 'DishToDoor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          fontFamily: "Montserrat",
        ),
        home: MyApp());
  }
}

Widget loading() {
  return MaterialApp(
      title: 'DishToDoor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        fontFamily: "Montserrat",
      ),
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ));
}

Future<void> somethingWentWrong(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Something went wrong!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Ensure you have a stable internet connection'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () async {},
          ),
        ],
      );
    },
  );
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  String _token;

  Future<void> saveTokenToDatabase(String _token) async {
    if (await storage.containsKey(key: 'email') == false) {
      print("error not logged in");
      return;
    }
    print("SAVING TOKEN TO BACKEND");
    print("token: " + _token.toString());
    String resT = await storage.read(key: "token");
    String resE = await storage.read(key: "email");
    String resP = await storage.read(key: "pass");
    String resType = await storage.read(key: "type");
    print(resE);
    print(resP);
    print(resType);

    if (resType == "eater") {
      print("communicating with backend");
      String token = await storage.read(key: 'token');
      final http.Response response =
          await http.post(baseURL + '/eater/api/device/register',
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': "Bearer " + token.toString(),
              },
              body: jsonEncode(<String, String>{
                "token": _token,
              }));
      print(response.statusCode);
      if (response.statusCode == 200) {
        dynamic decoded = jsonDecode(response.body);
        print("Received: " + decoded.toString());
        bool success = decoded['success'];
        if (success) {
          //_registerSuccessfulAlert();
          print("Successful eater notification adding");
        } else {
          print("Error in eater notification adding: " + decoded['error']);
        }
      } else {
        print("An unkown error occured notif eater");
      }
    } else {
      String token = await storage.read(key: 'token');
      final http.Response response =
          await http.post(baseURL + '/cook/api/device/register',
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': "Bearer " + token.toString(),
              },
              body: jsonEncode(<String, String>{
                "token": _token,
              }));

      if (response.statusCode == 200) {
        dynamic decoded = jsonDecode(response.body);
        print("Received: " + decoded.toString());
        bool success = decoded['success'];
        if (success) {
          print("Successful cook notification adding");
          //print("Your token is" + globals.token);

        } else {
          print("Error cook notification adding: " + decoded['error']);
        }
      } else {
        print("Error: " + response.statusCode.toString());
        print("An unkown error occured");
      }
    }
  }

  Future<String> getTokenNotification() async {
    print("GETTING TOKEN NOTIFICATION");
    String temp = await FirebaseMessaging.instance.getToken();
    setState(() {
      _token = temp;
    });
    return _token;
  }

  void _messageRouting(RemoteMessage message) {
    print("message routing: " + message.data["type"].toString());
    switch (message.data['type']) {
      case "eater_order_approved":
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => PageNavigatorEater(
                indexInput: 1,
              ),
            ),
          );
        }
        break;

      case "eater_order_rejected":
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => PageNavigatorEater(
                indexInput: 1,
              ),
            ),
          );
        }
        break;

      case "eater_order_complete":
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => PageNavigatorEater(
                indexInput: 1,
              ),
            ),
          );
        }
        break;

      case "eater_order_ready":
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => PageNavigatorEater(
                indexInput: 1,
              ),
            ),
          );
        }
        break;

      case "eater_order_cancelled":
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => PageNavigatorEater(
                indexInput: 1,
              ),
            ),
          );
        }
        break;

      case "cook_order_pending":
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => PageNavigatorCook(
                indexInput: 2,
              ),
            ),
          );
        }
        break;

      default:
        {}
        break;
    }
  }

  void initState() {
    super.initState();

    //storing unique user token for the first time
    getTokenNotification().then((value) {
      // Save the initial token to the database
      saveTokenToDatabase(value);
    });

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage message) {
    //   print("in ini Message");
    //   if (message.data != null) {
    //     print(message.data["type"]);
    //     if (message.data['type'] == "profile") {
    //       Navigator.of(context).push(
    //         MaterialPageRoute(
    //           builder: (BuildContext context) => ProfileEater(),
    //         ),
    //       );
    //     }
    //   }
    // });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("in listen yes");
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      print(notification.toString());
      print(android.toString());
      if (notification != null && android != null) {
        _messageRouting(message);

        //TODO remove only for debug
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      if (message != null) {
        _messageRouting(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'DishToDoor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          fontFamily: "Montserrat",
        ),
        home: SplashScreen());
  }
}
