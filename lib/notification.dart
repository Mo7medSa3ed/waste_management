import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:waset_management/main.dart';
import 'package:waset_management/navigator.dart';
import 'package:waset_management/screans/main.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

final androidDetails = NotificationDetails(
    android: AndroidNotificationDetails(
  channel.id,
  channel.name,
  channelDescription:channel.description,
  color: Colors.blue,
  playSound: true,
  icon: '@mipmap/ic_launcher',
));

showNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  if (notification != null) {
    flutterLocalNotificationsPlugin.show(notification.hashCode,
        notification.title, notification.body, androidDetails,
        payload: message.data['pos']);
  }
}

handleNotification() async {
  if (user['type'] == "user") return;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  _firebaseMessaging.requestPermission(
      sound: true, badge: true, alert: true, provisional: true);
  await _firebaseMessaging.subscribeToTopic('pushNotifications');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showNotification(message);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    Nav.goToScreanAndRemoveUntill(MainScrean(
      currantidx: 1,
      initialpos: LatLng(double.parse(message.data['pos'].split('/')[1]),
          double.parse(message.data['pos'].split('/')[1])),
    ));
  });
  FirebaseMessaging.onBackgroundMessage((message) async {
    await Firebase.initializeApp();
    Nav.goToScreanAndRemoveUntill(MainScrean(
      currantidx: 1,
      initialpos: LatLng(double.parse(message.data['pos'].split('/')[1]),
          double.parse(message.data['pos'].split('/')[1])),
    ));
  });
}

sendNotification(String title, String body ,String pos ) async {
  final notification = {
    "to": "/topics/pushNotifications",
    "notification": {"title": title, "body": body},
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "sound": "default",
      "status": "done",
      "pos": pos,
    }
  };
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'key=AAAAGILtE4U:APA91bGLNS2XAelIGAA2bDkSWBD21fh-LV4BU1zOVMDqhLuhDXeO2HiFCLMWWBFfTvawSaYgHBR6TG5Rp-GBlZb2kTULJSWL3GzweleLTvUdjszmrNTwhINOP4_AdFHJp38alpaZOckK'
  };

  await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
      body: jsonEncode(notification),
      headers: headers,
      encoding: Encoding.getByName('utf-8'));
}
