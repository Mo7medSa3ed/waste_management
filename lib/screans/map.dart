import 'dart:async';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waset_management/constants.dart';
import 'package:waset_management/main.dart';
import 'package:waset_management/widgets/primary_text.dart';

class Map extends StatefulWidget {
  const Map({this.lat, this.lng, Key? key}) : super(key: key);
  final double? lat, lng;
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  late LatLng initialPosition;
  List<Marker> markers = [];
  late GoogleMapController _controller;
  List<QueryDocumentSnapshot> baskets = [];
  late StreamSubscription subscription;

  getBaskets() {
    FirebaseFirestore.instance.collection('baskets').get().then((value) async {
      baskets = value.docs.toList();
      final changes = (await FirebaseDatabase.instance.ref().onValue.first)
          .snapshot
          .children
          .toList();

      await makeMarkers(value.docs, changes);
      setState(() {});
      listenToSensorsCollection();
    });
  }

  listenToSensorsCollection() {
    subscription =
        FirebaseDatabase.instance.ref().onValue.listen((event) async {
      await makeMarkers(baskets, event.snapshot.children.toList());
      setState(() {});
    });
  }

  makeMarkers(List docs, List changes) async {
    markers.clear();
    for (var e in docs) {
      final doc = changes.firstWhere((c) => c.key == e.id);
      markers.add(
        Marker(
            markerId: MarkerId(e.id),
            onTap: () =>
                showDialogForTrash(e, (doc.value / e['capacity']) * 100),
            icon: await createCustomMarker(
                getTrashImage(e['type'], e['capacity'], doc.value)),
            infoWindow: e['type'] != 'recycling'
                ? InfoWindow.noText
                : InfoWindow(title: e['name']),
            position: LatLng(double.parse(e['lat']), double.parse(e['lng']))),
      );
    }
  }

  

  showDialogForTrash(trash, double currant) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BatteryIndicator(
                style: BatteryIndicatorStyle.skeumorphism,
                size: 80,
                batteryFromPhone: false,
                colorful: true,
                batteryLevel: currant.toInt(),
                showPercentSlide: true,
                mainColor: kprimary,
                percentNumSize: 24,
                showPercentNum: true,
                ratio: 5,
              ),
              const SizedBox(height: 16),
              Image.network(
                trash['img'],
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 16),
              // if (currant.toInt() == 100)
              // if (false)
              //   TextButton(
              //       onPressed: () async {
              //         // await goToNearstBasket();
              //       },
              //       child: const Text('للذهاب لاقرب سلة غير ممتلئة اضغط هنا')),
              const SizedBox(height: 16),
              PrimaryText(
                text: trash['address'],
                textAlign: TextAlign.end,
              )
            ],
          ),
        ),
      ),
    );
  }

  
  @override
  void initState() {
    super.initState();
    if (widget.lat == null || widget.lng == null) {
      initialPosition = const LatLng(30.586745345838313, 31.524730325944617);
    } else {
      initialPosition = LatLng(widget.lat!, widget.lng!);
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
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
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: GoogleMap(
        buildingsEnabled: true,
        compassEnabled: true,
        trafficEnabled: true,
        initialCameraPosition:
            CameraPosition(target: initialPosition, zoom: 25),
        markers: markers.toSet(),
        onMapCreated: (GoogleMapController controller) async {
          await rootBundle
              .loadString('assets/mapStyle/dark_map_style.txt')
              .then((value) => controller.setMapStyle(value));
          _controller = controller;
          getBaskets();
        },
      ),
    );
  }
}
