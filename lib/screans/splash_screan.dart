import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waset_management/constants.dart';
import 'package:waset_management/main.dart';
import 'package:waset_management/navigator.dart';
import 'package:waset_management/screans/getstarted_screan.dart';
import 'package:waset_management/screans/main.dart';

class SplashScrean extends StatefulWidget {
  const SplashScrean({Key? key}) : super(key: key);

  @override
  State<SplashScrean> createState() => _SplashScreanState();
}

class _SplashScreanState extends State<SplashScrean> {
  getUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user['email'])
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        user = value.docs.first.data();
        setState(() {});
        Future.delayed(Duration.zero, () {
          Nav.goToScreanAndRemoveUntill(const MainScrean());
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      getUser();
    } else {
      Future.delayed(Duration.zero, () {
        Nav.goToScreanWithReplaceMent(const GetStarted());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/Welcome.png'),
          fit: BoxFit.fill,
        )),
        child: Column(
          children: const [
            Spacer(flex: 3),
            CircularProgressIndicator(
              color: kprimary,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
