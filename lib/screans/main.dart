import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waset_management/notification.dart';
import 'package:waset_management/screans/Home.dart';
import 'package:waset_management/screans/map.dart';
import 'package:waset_management/screans/profile_screan.dart';

class MainScrean extends StatefulWidget {
  const MainScrean({this.currantidx, this.initialpos, Key? key})
      : super(key: key);
  final int? currantidx;
  final LatLng? initialpos;

  @override
  _MainScreanState createState() => _MainScreanState();
}

class _MainScreanState extends State<MainScrean> {
  int currantIdx = 0;
  List pages = [];

  @override
  void initState() {
    super.initState();
    if (widget.currantidx != null) {
      currantIdx = widget.currantidx!;
    }
    pages = [
      const Home(),
      if (widget.initialpos == null)
        const Map()
      else
        Map(
          lat: widget.initialpos!.latitude,
          lng: widget.initialpos!.longitude,
        ),
      const ProfileScrean()
    ];

    handleNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: currantIdx,
        onTap: (value) {
          setState(() {
            currantIdx = value;
          });
        },
      ),
      body: pages[currantIdx],
    );
  }
}
