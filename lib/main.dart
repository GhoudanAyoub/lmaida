import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:lmaida/utils/providers.dart';
import 'package:lmaida/utils/routes.dart';
import 'package:lmaida/utils/theme.dart';
import 'package:provider/provider.dart';

import 'SplashScreen/splash_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(var message) async {
  await Firebase.initializeApp();
  print('Handling a background message $message');
}

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<dynamic> _myBackgroundMessageHandler(
    Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
// Handle data message
    var data = message['data'] ?? message;
    String orderId = data['orderId'];
    String itemId = data['itemId'];
    print("fcmtest :" + orderId);
    print("fcmtest :" + itemId);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.red[900]);
    return MultiProvider(
        providers: providers,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lmaida',
          theme: theme(),
          initialRoute: SplashScreen.routeName,
          routes: routes,
        ));
  }
}
