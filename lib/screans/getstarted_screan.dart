import 'package:flutter/material.dart';
import 'package:waset_management/navigator.dart';
import 'package:waset_management/screans/login_screan.dart';
import 'package:waset_management/widgets/primary_button.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/Welcome.png'), fit: BoxFit.fill),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 5),
              PrimaryButton(
                  text: "Login",
                  onTap: () => Nav.goToScrean(const LoginScrean(login: true))),
              const SizedBox(height: 24),
              PrimaryButton(
                  text: "Create Account",
                  onTap: () => Nav.goToScrean(const LoginScrean(login: false))),
              const Spacer(),
            ],
          )),
    );
  }
}
