// ignore_for_file: prefer_const_constructors, duplicate_ignore, prefer_const_literals_to_create_immutables

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:signin_firebase/model/pushnotification_model.dart';
import 'package:signin_firebase/screens/notification_badge.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  //initilize some values
  late final FirebaseMessaging _messaging;
  late int _totalNotificationCounter;

  //model
  PushedNotification? _notificationInfo;

  //register notification

  void registerNotification() async {
    await Firebase.initializeApp();
    //instance for firebase messaging

    _messaging = FirebaseMessaging.instance;

    //three type of state in notification
    //not deteramine (null) , granted (true) and decline (false)

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushedNotification notification = PushedNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          databody: message.data['body'],
        );
        setState(() {
          _totalNotificationCounter++;
          _notificationInfo = notification;
        });
        if (notification != null) {
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading:
                NotificationBadge(totalNotification: _totalNotificationCounter),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      print("Permission declined By user");
    }
  }

  checkForIntilalMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? intialmessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (intialmessage != null) {
      PushedNotification notification = PushedNotification(
        title: intialmessage.notification!.title,
        body: intialmessage.notification!.body,
        dataTitle: intialmessage.data['title'],
        databody: intialmessage.data['body'],
      );
      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    }
  }

  @override
  void initState() {
    //when app is in background

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      PushedNotification notification = PushedNotification(
        title: message.notification!.title,
        body: message.notification!.body,
        dataTitle: message.data['title'],
        databody: message.data['body'],
      );
      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    });
    //noramal notification
    registerNotification();
    //when app is in terminated state
    checkForIntilalMessage();

    _totalNotificationCounter = 0;

    super.initState();
  }

  //cheack for  intial message that we recive

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("pushed notification"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ignore: prefer_const_constructors
            Text(
              "Flutter Pushed Notification",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            SizedBox(
              height: 12.0,
            ),
            //showing notification badge
            //count the total notification that we recive
            NotificationBadge(totalNotification: _totalNotificationCounter),
            SizedBox(
              height: 12.0,
            ),
            //if notification Info is not Null
            _notificationInfo != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "TITLE: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: 9.0,
                      ),
                      Text(
                        "BODY: ${_notificationInfo!.databody ?? _notificationInfo!.body}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
