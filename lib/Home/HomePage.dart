import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lmaida/sidebar/sidebar_layout.dart';

class HomePage extends StatefulWidget {
  final position;

  const HomePage({Key key, this.position}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getNotif();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: new WillPopScope(
      onWillPop: () async => false,
      child: SideBarLayout(),
    ));
  }

  void getNotif() {
    /* var result = await FlutterNotificationChannel.registerNotificationChannel(
        description: 'My test channel',
        id: 'com.softmaestri.testchannel',
        importance: NotificationImportance.IMPORTANCE_HIGH,
        name: 'Flutter channel test name');*/

    FirebaseMessaging.onMessage.listen((var message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        /*flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  color: Colors.blue,
                  playSound: true,
                  icon: '@mipmap/ic_launcher',
                ),
                iOS: null));*/
        debugPrint('${notification.title} ${notification.body}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((var message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body)],
                  ),
                ),
              );
            });
      }
    });
  }
}
