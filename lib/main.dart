import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waset_management/constants.dart';
import 'package:waset_management/navigator.dart';
import 'package:waset_management/notification.dart';
import 'package:waset_management/screans/main.dart';
import 'package:waset_management/screans/splash_screan.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
late SharedPreferences prefs;
var user;
final navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  if (prefs.get('user') != null) {
    user = jsonDecode(prefs.getString('user')!);
  }
  ////////////////////
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: initializationSettingsAndroid),
    onSelectNotification: (payload) async {
      if (payload == null) return;
      Nav.goToScreanAndRemoveUntill(MainScrean(
        currantidx: 1,
        initialpos: LatLng(double.parse(payload.split('/')[1]),
            double.parse(payload.split('/')[1])),
      ));
      return null;
    },
  );
  ////////////////////
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste Management',
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.blue,
        primaryColor: kprimary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: kprimary,
          primary: kprimary,
        ),
      ),
      home: const SplashScrean(),
    );
  }
}
