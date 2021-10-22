import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lmaida/sidebar/sidebar_layout.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  final position;

  const HomePage({Key key, this.position}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _token;
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((var message) async {
      RemoteNotification notification = message.notification;
      var android = message.notification?.android;
      if (notification != null && android != null) {
        var android = AndroidNotificationDetails(
            'id', 'channel ', 'description',
            priority: Priority.High,
            importance: Importance.High,
            playSound: true,
            icon: '@drawable/ic_launcher');
        var iOS = IOSNotificationDetails();

        await FirebaseMessaging.instance.getToken().then((value) {
          setState(() {
            _token = value;
          });
        });
        if (message.messageId.contains(_token))
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              new NotificationDetails(android, iOS));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((var message) {
      RemoteNotification notification = message.notification;

      var android = message.notification?.android;
      if (notification != null &&
          android != null &&
          message.messageId.contains(_token)) {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: new WillPopScope(
      onWillPop: () async => false,
      child: SideBarLayout(),
    ));
  }
}
