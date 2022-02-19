import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:waset_management/constants.dart';
import 'package:waset_management/main.dart';
import 'package:waset_management/navigator.dart';
import 'package:waset_management/widgets/primary_button.dart';
import 'package:waset_management/widgets/primary_text.dart';

class RateUsScrean extends StatefulWidget {
  const RateUsScrean({Key? key}) : super(key: key);

  @override
  _RateUsScreanState createState() => _RateUsScreanState();
}

class _RateUsScreanState extends State<RateUsScrean> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  double rating = 1;

  addRateToUser() async {
    final firestore = FirebaseFirestore.instance.collection('users');
    firestore
        .where('email', isEqualTo: user['email'])
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        await firestore.doc(value.docs.first.id).update({
          "comment": controller.text.trim(),
          "rate": "$rating"
        }).then((value) {
          Nav.pop();
          showAlert('Your rating added successfully . Thank You .');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate US'),
      ),
      body: 
      
      ListView(
        padding: const EdgeInsets.all(kdefultPadding),
        children: [
          Image.asset('assets/review.png'),
          const SizedBox(height: kdefultPadding),
          const PrimaryText(text: '\t\tWrite your openion ....'),
          const SizedBox(height: kdefultPadding),
          Container(
            padding: const EdgeInsets.all(kdefultPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'comment required *';
                  }
                  return null;
                },
                decoration: const InputDecoration(border: InputBorder.none),
                maxLines: 4,
                maxLength: 500,
              ),
            ),
          ),
          const SizedBox(height: kdefultPadding),
          Row(
            children: [
              const Spacer(),
              RatingBar.builder(
                initialRating: 1,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (r) {
                  setState(() {
                    if (r < 1) {
                      rating = 1;
                    } else {
                      rating = r;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: kdefultPadding * 4),
          PrimaryButton(
              text: 'Send',
              onTap: () async {
                formKey.currentState!.validate();
                if (formKey.currentState!.validate()) {
                  await addRateToUser();
                }
              })
        ],
      ),
    );
  }
}
