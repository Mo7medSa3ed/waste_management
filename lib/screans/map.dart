import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  List<QueryDocumentSnapshot> baskets = [];
  late LatLng initialPosition;
  List<Marker> markers = [];

  getBasketsAndShowMarkers() {
    FirebaseFirestore.instance.collection('baskets').get().then((value) {
      setState(() {
        baskets = value.docs;
      });
      markers.clear();
      for (var e in baskets) {
        markers.add(
          Marker(
              markerId: MarkerId(e.id),
              infoWindow: InfoWindow(title: e['name']),
              position: LatLng(double.parse(e['lat']), double.parse(e['lng']))),
        );
      }
      setState(() {});
    });
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
        mapType: MapType.hybrid,
        buildingsEnabled: true,
        compassEnabled: true,
        trafficEnabled: true,
        initialCameraPosition:
            CameraPosition(target: initialPosition, zoom: 25),
        markers: markers.toSet(),
        onMapCreated: (GoogleMapController controller) {
          getBasketsAndShowMarkers();
        },
      ),
    );
  }
}
