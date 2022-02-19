import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:waset_management/constants.dart';

class AllRatesScrean extends StatefulWidget {
  const AllRatesScrean({Key? key}) : super(key: key);

  @override
  _AllRatesScreanState createState() => _AllRatesScreanState();
}

class _AllRatesScreanState extends State<AllRatesScrean> {
  List<QueryDocumentSnapshot> usersRates = [];
  bool success = false;
  @override
  void initState() {
    super.initState();
    getAllrates();
  }

  getAllrates() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('comment', isNotEqualTo: '')
        .get()
        .then((value) {
      success = true;
      usersRates = value.docs;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Rates'),
      ),
      body: !success && usersRates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : success && usersRates.isEmpty
              ? const Center(child: Text('No Rates Found...'))
              : ListView.builder(
                  itemCount: usersRates.length,
                  padding:
                      const EdgeInsets.symmetric(vertical: kdefultPadding / 2),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      child: ExpansionTile(
                        expandedAlignment: Alignment.topLeft,
                        childrenPadding: const EdgeInsets.all(kdefultPadding),
                        leading: const CircleAvatar(
                          backgroundColor: kprimary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(usersRates[index]['username']),
                        subtitle: RatingBarIndicator(
                          itemCount: 5,
                          itemSize: 15,
                          rating: double.parse(usersRates[index]['rate']),
                          itemBuilder: (context, index) {
                            return const Icon(Icons.star, color: Colors.amber);
                          },
                        ),
                        children: [Text(usersRates[index]['comment'])],
                      ),
                    );
                  },
                ),
    );
  }
}
