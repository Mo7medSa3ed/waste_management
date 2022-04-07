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
  num distance = 0;

  getColor() {
    final capacity = baskets[selectedBasket]['data']['capacity'];
    if (distance > ((capacity / 3) * 2.3)) {
      return Colors.red.shade900;
    } else if (distance <= capacity / 2) {
      return kprimary;
    } else {
      return Colors.yellow.shade700;
    }
  }

  @override
  void initState() {
    super.initState();
    getPosition().then((value) => userPosition = value);
    getAllBaskets();
  }

  getAllBaskets() async {
    FirebaseFirestore.instance
        .collection('baskets')
        .where('type', isNotEqualTo: 'recycling')
        .get()
        .then((value) {
      setState(() {
        baskets =
            value.docs.reversed.map((e) => {'data': e, 'exist': true}).toList();
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
      final capacity = baskets[selectedBasket]['data']['capacity'];
      if (distance >= capacity && dis >= capacity) return;
      distance = dis;
      if (distance >= capacity) {
        distance = capacity;
        final pos =
            "${baskets[selectedBasket]['lat']}/${baskets[selectedBasket]['lng']}";
        await sendNotification("Mohamed", "Go To Basket To empty him...", pos);
      }
      setState(() {});
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
          SizedBox(
              height: distance >= baskets[selectedBasket]['data']['capacity']
                  ? 0.0
                  : 10.0),
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
                      heightPercentange: 0.0,
                      wavePhase: 0,
                      backgroundColor: backgroundColor,
                      backgroundImage: backgroundImage,
                      size: const Size(double.infinity, double.infinity),
                      waveAmplitude: -8,
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
                setState(() {});
                getSensor();
              },
              indicatorColor: Colors.white,
              indicatorWeight: 4,
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
                        distance >= baskets[selectedBasket]['data']['capacity']
                            ? Colors.red.shade500
                            : Colors.white,
                    config: CustomConfig(
                      gradients: List.generate(4, (index) {
                        return [getColor(), getColor().withOpacity(0.2)];
                      }),
                      durations: List.generate(4, (index) => 1200),
                      heightPercentages: List.generate(
                          4,
                          (index) =>
                              1 -
                              (distance /
                                  baskets[selectedBasket]['data']['capacity'])),
                      blur: const MaskFilter.blur(BlurStyle.normal, 0.0),
                      gradientBegin: Alignment.bottomCenter,
                      gradientEnd: Alignment.topCenter,
                    ),
                  );
          }).toList(),
        ),
      ),
    );
  }
}
