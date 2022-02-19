import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waset_management/constants.dart';
import 'package:waset_management/main.dart';
import 'package:waset_management/navigator.dart';
import 'package:waset_management/screans/main.dart';
import 'package:waset_management/widgets/primary_button.dart';
import 'package:waset_management/widgets/primary_text.dart';

class LoginScrean extends StatefulWidget {
  const LoginScrean({this.login = true, Key? key}) : super(key: key);
  final bool login;
  @override
  _LoginScreanState createState() => _LoginScreanState();
}

class _LoginScreanState extends State<LoginScrean> {
  final userName = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future signin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.text, password: pass.text);
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.text.trim())
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          user = value.docs.first.data();
          await prefs.setString('user', jsonEncode(value.docs.first.data()));
          return Nav.goToScreanAndRemoveUntill(const MainScrean());
        }
      });
    } on FirebaseAuthException catch (e) {
      return showAlert(e.message ?? "");
    } catch (e) {
      return showAlert(e.toString());
    }
  }

  Future signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: pass.text);
      await FirebaseFirestore.instance.collection('users').add({
        'username': userName.text.trim(),
        'email': email.text.trim(),
        'type': 'user',
        'comment': '',
        'rate': '',
        'subscribe': false,
        'paid': false
      });
      await prefs.setString(
          'user',
          jsonEncode({
            'username': userName.text.trim(),
            'email': email.text.trim(),
            'type': 'user',
            'subscribe': false,
            'paid': false
          }));
      user = {
        'username': userName.text.trim(),
        'email': email.text.trim(),
        'type': 'user',
        'subscribe': false,
        'paid': false
      };

      Nav.goToScreanAndRemoveUntill(const MainScrean());
    } on FirebaseAuthException catch (e) {
      return showAlert(e.message ?? "");
    } catch (e) {
      return showAlert(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: formKey,
          child: ListView(
            children: [
              Container(
                height: 180,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: kprimary,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50))),
                child: Image.asset('assets/logo.png'),
              ),
              const SizedBox(height: kdefultPadding * 1),
              const Padding(
                padding: EdgeInsets.all(kdefultPadding * 1),
                child: PrimaryText(
                  text: 'Become part of the future',
                  fontWeight: FontWeight.w400,
                  fontSizeRatio: 2,
                ),
              ),
              const SizedBox(height: kdefultPadding * 2),
              if (!widget.login)
                Container(
                  margin: const EdgeInsets.all(kdefultPadding * 1),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kprimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextFormField(
                    controller: userName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'username required *';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'enter your username...',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.all(kdefultPadding * 1),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kprimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextFormField(
                  controller: email,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'email required *';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'enter your email...',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(kdefultPadding * 1),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kprimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextFormField(
                  controller: pass,
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'password required *';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'enter your password...',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              const SizedBox(height: kdefultPadding * 2),
              Padding(
                padding: const EdgeInsets.all(kdefultPadding * 1),
                child: PrimaryButton(
                    text: widget.login ? 'Login' : 'CreateAccount',
                    onTap: () async {
                      formKey.currentState!.validate();
                      if (formKey.currentState!.validate()) {
                        widget.login ? await signin() : await signup();
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
