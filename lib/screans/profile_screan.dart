import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waset_management/constants.dart';
import 'package:waset_management/main.dart';
import 'package:waset_management/navigator.dart';
import 'package:waset_management/screans/all_rates_screan.dart';
import 'package:waset_management/screans/getstarted_screan.dart';
import 'package:waset_management/screans/rate_screan.dart';
import 'package:waset_management/widgets/primary_button.dart';

class ProfileScrean extends StatefulWidget {
  const ProfileScrean({Key? key}) : super(key: key);

  @override
  _ProfileScreanState createState() => _ProfileScreanState();
}

class _ProfileScreanState extends State<ProfileScrean> {
  getUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user['email'])
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        user = value.docs.first.data();
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: kdefultPadding / 2),
      child: Column(
        children: [
          const SizedBox(height: kdefultPadding * 3),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
              backgroundColor: kprimary,
            ),
            title: Text(
              user['username'].toString().toUpperCase(),
              style: const TextStyle(fontSize: kdefaultTextSize * 2),
            ),
            subtitle: Text(user['email'],
                style: const TextStyle(fontSize: kdefaultTextSize * 1)),
          ),
          const SizedBox(height: kdefultPadding * 2),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              onTap: () {
                Nav.goToScrean(const RateUsScrean());
              },
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              leading: const CircleAvatar(
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                backgroundColor: kprimary,
              ),
              title: const Text('RateUs',
                  style: TextStyle(fontSize: kdefaultTextSize * 1.2)),
            ),
          ),
          const SizedBox(height: kdefultPadding / 2),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              onTap: () {
                Nav.goToScrean(const AllRatesScrean());
              },
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              leading: const CircleAvatar(
                child: Icon(
                  Icons.list_alt,
                  color: Colors.white,
                ),
                backgroundColor: kprimary,
              ),
              title: const Text('All users rates',
                  style: TextStyle(fontSize: kdefaultTextSize * 1.2)),
            ),
          ),
          const SizedBox(height: kdefultPadding * 8),
          if (user['type'] != 'user') ...[
            const Spacer(flex: 2),
            PrimaryButton(
                text: 'Signout',
                color: Colors.red.shade900,
                onTap: () async {
                  await prefs.clear();
                  await FirebaseAuth.instance.signOut();
                  Nav.goToScreanAndRemoveUntill(const GetStarted());
                }),
            const Spacer()
          ],
          if (user['type'] == 'user') ...[
            const Spacer(flex: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user['paid'] && user['subscribe'])
                  PrimaryButton(
                      text: 'unsubscribe',
                      onTap: () async {
                        await unsubscribe();
                        await getUser();
                      }),
                const SizedBox(width: kdefultPadding / 2),
                if (!user['subscribe'])
                  PrimaryButton(
                      text: 'Subscribe & Pay',
                      onTap: () async {
                        await subscribe();
                        await getUser();
                      }),
                const SizedBox(width: kdefultPadding / 2),
                PrimaryButton(
                    text: 'Signout',
                    color: Colors.red.shade900,
                    onTap: () async {
                      await prefs.clear();
                      await FirebaseAuth.instance.signOut();
                      Nav.goToScreanAndRemoveUntill(const GetStarted());
                    }),
              ],
            ),
            const Spacer()
          ],
        ],
      ),
    );
  }
}
