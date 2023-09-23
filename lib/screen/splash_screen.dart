import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:test1/main.dart';
import '../services/location_services.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('lib/videos/splashScreenvid.mp4')
      ..initialize().then((_) {
        _controller.setLooping(false);
        _controller.play().then((_) => setState(() {}));
      });

    // Tambahkan listener pada controller video
    _controller.addListener(_onVideoEnd);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> locationService() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionLocation;
    LocationData locData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionLocation = await location.hasPermission();
    if (permissionLocation == PermissionStatus.denied) {
      permissionLocation = await location.requestPermission();
      if (permissionLocation != PermissionStatus.granted) {
        return;
      }
    }

    locData = await location.getLocation();

    setState(() {
      UserLocation.lat = locData.latitude!;
      UserLocation.long = locData.longitude!;
    });
    Timer(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    });
  }

  // Fungsi untuk menangani event video selesai diputar
  void _onVideoEnd() {
    // Jika lokasi pengguna sudah didapatkan sebelum video selesai diputar

    Timer(const Duration(seconds: 6), () {
      locationService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          )
        ],
      ),
    );
  }
}
