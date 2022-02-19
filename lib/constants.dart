import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
