import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waset_management/main.dart';

const kprimary = Color(0xff4d8d6e);
const kblack = Colors.black87;

const kdefultPadding = 16.0;
const kdefaultTextSize = 16.0;

subscribe() async {
  await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: user['email'])
      .get()
      .then((value) async {
    if (value.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(value.docs.first.id)
          .update({
        'subscribe': true,
        'paid': true,
        'start': DateTime.now().toLocal().toString(),
        'end':
            DateTime.now().add(const Duration(days: 30)).toLocal().toString(),
      });
      showAlert('your are now subscribe successfully ...');
    }
  });
}

unsubscribe() async {
  await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: user['email'])
      .get()
      .then((value) async {
    if (value.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(value.docs.first.id)
          .update({
        'subscribe': false,
        'paid': false,
        'start': '',
        'end': '',
      });
      showAlert('your are now unsubscribe ...');
    }
  });
}

showAlert(String msg) {
  SnackBar snackbar = SnackBar(
    content: Text(
      msg,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: kprimary,
  );
  ScaffoldMessenger.of(navKey.currentContext!).showSnackBar(snackbar);
}

String getTrashImage(type, capacity, currant) {
  if (type == 'recycling') {
    return 'recycle.png';
  } else {
    if (currant > ((capacity / 3) * 2.3)) {
      return 'full.png';
    } else if (currant <= capacity / 2) {
      return 'empty.png';
    } else {
      return 'middle.png';
    }
  }
}

Future<Uint8List> getBytesFromAsset(String path) async {
  ByteData data = await rootBundle.load(path);
  Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: 90, targetHeight: 110);
  FrameInfo fi = await codec.getNextFrame();

  return (await fi.image.toByteData(format: ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<BitmapDescriptor> createCustomMarker(String assetImage) async {
  final res =
      BitmapDescriptor.fromBytes(await getBytesFromAsset('assets/$assetImage'));
  return res;
}

Future<Position> getPosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {

    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
  
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 
  return await Geolocator.getCurrentPosition();
}