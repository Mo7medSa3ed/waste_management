
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:waset_management/constants.dart';
import 'package:waset_management/main.dart';
import 'package:waset_management/notification.dart';
import 'package:waset_management/widgets/primary_text.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map> baskets = [];
  int selectedBasket = 0;
  double distance = 0;
  getColor() {
    return distance >= 1000 ? Colors.red.shade900 : kprimary;
  }

  @override
  void initState() {
    super.initState();
    getAllBaskets();
  }

  getAllBaskets() async {
    FirebaseFirestore.instance.collection('baskets').get().then((value) {
      setState(() {
        baskets = value.docs.map((e) => {'data': e, 'exist': true}).toList();
      });
      getSensor();
    });
  }

  getSensor() async {
    FirebaseDatabase.instance
        .ref()
        .child(baskets[selectedBasket]['data'].id)
        .onValue
        .listen((event) async {
      baskets[selectedBasket]['exist'] = event.snapshot.exists;
      if (!event.snapshot.exists) {
        setState(() {});
        return;
      }

      final dis = double.parse(event.snapshot.value.toString());
      if (distance >= 1000 && dis >= 1000) return;
      distance = dis;
      if (distance >= 1000) {
        distance = 1000;
        final pos =
            "${baskets[selectedBasket]['lat']}/${baskets[selectedBasket]['lng']}";
        await sendNotification("Mohamed", "Go To Basket To empty him...", pos);
      }

      if (mounted) setState(() {});
    });
  }

  _buildCard({
    Config? config,
    Color backgroundColor = Colors.transparent,
    DecorationImage? backgroundImage,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(
            'assets/trash.png',
            fit: BoxFit.cover,
            color: getColor(),
          ),
          SizedBox(height: distance >= 1000 ? 0.0 : 10.0),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                  decoration: BoxDecoration(
                    color: getColor(),
                    border: Border(
                        bottom: BorderSide(color: getColor(), width: 6),
                        left: BorderSide(color: getColor(), width: 6),
                        right: BorderSide(color: getColor(), width: 6)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    child: WaveWidget(
                      config: config!,
                      waveFrequency: 0,
                      heightPercentange: 0.1,
                      wavePhase: 0,
                      isLoop: false,
                      backgroundColor: backgroundColor,
                      backgroundImage: backgroundImage,
                      size: const Size(double.infinity, double.infinity),
                      waveAmplitude: 0,
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user['subscribe'] == null ||
        (!user['subscribe']) && user['type'] == 'user') {
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/unlock.png'),
          const SizedBox(height: kdefultPadding),
          const PrimaryText(
            text: 'please subscribe from profile to join with us...',
          ),
        ],
      );
    }

    if (baskets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return DefaultTabController(
      length: baskets.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Wasty..',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
          backgroundColor: kprimary,
          elevation: 1,
          bottom: TabBar(
              onTap: (value) {
                selectedBasket = value;
                getSensor();
              },
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              // isScrollable: true,
              labelColor: Colors.white,
              tabs: baskets
                  .map((e) => Tab(
                        child: Text(e['data']['name'] ?? ''),
                      ))
                  .toList()),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: baskets.map<Widget>((e) {
            return !e['exist']
                ? Container()
                : _buildCard(
                    backgroundColor:
                        distance >= 1000 ? Colors.red.shade500 : Colors.white,
                    config: CustomConfig(
                      gradients: List.generate(4, (index) {
                        return distance >= 1000
                            ? [Colors.red.shade900, Colors.red]
                            : [
                                kprimary.withOpacity(0.9),
                                kprimary.withOpacity(0.1)
                              ];
                      }),
                      durations: List.generate(4, (index) => 1200),
                      heightPercentages:
                          List.generate(4, (index) => 1 - (distance / 1000)),
                      blur: const MaskFilter.blur(BlurStyle.normal, 0.0),
                      gradientBegin: Alignment.bottomLeft,
                      gradientEnd: Alignment.topRight,
                    ),
                  );
          }).toList(),
        ),
      ),
    );
  }
}
