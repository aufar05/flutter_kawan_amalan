import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as Lokasi;
// ignore: import_of_legacy_library_into_null_safe
import 'package:adhan/adhan.dart';
import 'package:test1/screen/navigasi_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cron/cron.dart';
import '../services/location_services.dart';
import '../services/notification_services.dart';
import '../util/background_adzan.dart';

class WaktuAdzan extends StatefulWidget with WidgetsBindingObserver {
  const WaktuAdzan({Key? key}) : super(key: key);

  @override
  State<WaktuAdzan> createState() => _WaktuAdzanState();
}

class _WaktuAdzanState extends State<WaktuAdzan> with WidgetsBindingObserver {
  final Cron _cron = Cron();
  final prayerNames = ['Subuh', 'Syuruq', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
  late final List<bool> _isLoading = List.filled(prayerNames.length, false);
  late final List<bool> _notificationEnabled =
      List.filled(prayerNames.length, false);

  String kota = '';
  String kecamatan = '';

  Lokasi.Location location = Lokasi.Location();
  Lokasi.LocationData? _currentPosition;
  double? latitude, longitude;
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationSettings();
    getLocation();
    _configureCron();
    // Jalankan _updateNotification() setiap jam 00.00
  }

  void _configureCron() {
    // Menjadwalkan cron untuk menjalankan metode _printDebugConsole setiap jam 00.00
    _cron.schedule(Schedule.parse('0 0 * * *'), () async {
      for (int i = 0; i < prayerNames.length; i++) {
        _updateNotification(i);
      }
    });
  }

  void _updateNotification(int i) async {
    int id = i + 1;
    final myCoordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.dubai.getParameters();
    params.madhab = Madhab.shafi;
    params.adjustments.fajr = -6;
    params.adjustments.isha = 2;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    final prayerTimeList = [
      prayerTimes.fajr,
      prayerTimes.sunrise,
      prayerTimes.dhuhr,
      prayerTimes.asr,
      prayerTimes.maghrib,
      prayerTimes.isha
    ];
    debugPrint(
        'Notification Scheduled for  ${prayerNames[i]} at ${DateFormat.jm().format(prayerTimeList[i])} with id $id  ');

    if (_notificationEnabled[i]) {
      // print(
      //     "Updating notification for $i: ${prayerNames[i]} at ${prayerTimeList[i]}");
      await NotificationService().cancelNotification(id);
      await NotificationService().scheduleCustomTimeNotification(
          id,
          prayerTimeList[i].hour,
          prayerTimeList[i].minute,
          prayerNames[i] == "Syuruq" ? "Syuruq" : prayerNames[i],
          prayerNames[i] == "Syuruq"
              ? "Selamat Menjalankan aktifitas "
              : "Waktunya untuk sholat ${prayerNames[i]}");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  // void listenNotification() =>
  //     NotificationApi.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const MyHomePage(
                  index: 1,
                )),
      );

  void _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < prayerNames.length; i++) {
        _notificationEnabled[i] = prefs.getBool("notification_$i") ?? false;
        // print('Data berhasil terload');
      }
    });
  }

  void _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < prayerNames.length; i++) {
      prefs.setBool("notification_$i", _notificationEnabled[i]);
    }
  }

  Future<void> getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(UserLocation.lat, UserLocation.long);

    // print(placemark[0].administrativeArea);
    // print(placemark[0].subAdministrativeArea);
    // print(DateTime.now().add(const Duration(seconds: 10)));

    setState(() {
      kota = placemark[0].administrativeArea!;
      kecamatan = placemark[0].subAdministrativeArea!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.4),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 24, 81, 130),
            centerTitle: true,
            // title: Container(
            //   decoration: BoxDecoration(color: Colors.white),
            //   child: Text(
            //     'Waktu Adzan',
            //     style: TextStyle(color: Colors.black),
            //   ),
            // ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                child: Container(
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.75)),
                  child: Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.all(size.height * 0.01),
                        child: Text(
                          '$kota' ',' '$kecamatan',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            // You can adjust the multiplication factor (0.04) as needed
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            flexibleSpace: Opacity(
              opacity: 0.75,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.elliptical(100, 150),
                    bottomRight: Radius.elliptical(100, 150)),
                child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: BackgroundChanger.getBackgroundAsset(),
                            fit: BoxFit.fill))),
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: getLoc(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: const Color.fromRGBO(224, 224, 224, 1),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.grey),
                ),
              );
            }

            final myCoordinates = Coordinates(latitude, longitude);
            final params = CalculationMethod.karachi.getParameters();
            params.madhab = Madhab.shafi;
            params.adjustments.fajr = -9;
            params.adjustments.dhuhr = -1;

            final prayerTimes = PrayerTimes.today(myCoordinates, params);

            final prayerTimeList = [
              prayerTimes.fajr,
              prayerTimes.sunrise,
              prayerTimes.dhuhr,
              prayerTimes.asr,
              prayerTimes.maghrib,
              prayerTimes.isha
            ];

            Future<void> _toggleNotification(int i) async {
              int id = i + 1;
              setState(() {
                _notificationEnabled[i] = !_notificationEnabled[i];
                // print(
                //     "Notification toggle for ${prayerNames[i]}: $_notificationEnabled");
                _saveNotificationSettings();
              });

              if (!_notificationEnabled[i]) {
                await NotificationService().cancelNotification(id);
                debugPrint(
                    'Notification cancelled for ${prayerNames[i]} with id $id');
              } else {
                debugPrint(
                    'Notification Scheduled for  ${prayerNames[i]} at ${DateFormat.jm().format(prayerTimeList[i])} with id $id  ');
              }
            }

            return Container(
              height: size.height * 0.6,
              color: const Color.fromRGBO(224, 224, 224, 1),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01),
                  for (int i = 0; i < prayerNames.length; i++)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.025),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              prayerNames[i],
                              style: TextStyle(
                                  fontSize: size.height * 0.02,
                                  fontWeight: FontWeight.bold,
                                  height: size.height * 0.0015),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat.jm().format(prayerTimeList[i]),
                              style: TextStyle(
                                fontSize: size.height * 0.021,
                                fontWeight: FontWeight.bold,
                                height: size.height * 0.0015,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(size.height * 0.01),
                            child: SizedBox(
                              height: size.height * 0.05,
                              width: size.width * 0.2,
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _isLoading[i] = true;
                                  });

                                  Future.delayed(const Duration(seconds: 1),
                                      () async {
                                    int id = i + 1;

                                    await NotificationService()
                                        .scheduleCustomTimeNotification(
                                      id,
                                      prayerTimeList[i].hour,
                                      prayerTimeList[i].minute,
                                      prayerNames[i] == "Syuruq"
                                          ? "Syuruq"
                                          : prayerNames[i],
                                      prayerNames[i] == "Syuruq"
                                          ? "Selamat Menjalankan aktifitas "
                                          : "Waktunya untuk sholat ${prayerNames[i]}",
                                    );

                                    _toggleNotification(i);

                                    setState(() {
                                      _isLoading[i] = false;
                                    });
                                  });
                                },
                                child: _isLoading[i]
                                    ? const SpinKitDoubleBounce(
                                        color: Colors.white,
                                        size: 24.0,
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _notificationEnabled[i]
                                                ? Icons.notifications_active
                                                : Icons.notifications_off,
                                            color: Colors.white,
                                            size: size.height * 0.03,
                                          ),
                                          SizedBox(width: size.width * 0.01),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     await NotificationService().showNotification(
                  //       id: 1,
                  //       title: 'Test Notification',
                  //       body: 'This is a test notification',
                  //     );
                  //   },
                  //   child: Text('Check Notifikasi'),
                  // )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  getLoc() async {
    bool serviceEnabled;
    Lokasi.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == Lokasi.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != Lokasi.PermissionStatus.granted) {
        return;
      }
    }
    _currentPosition = await location.getLocation();
    latitude = _currentPosition!.latitude!;
    longitude = _currentPosition!.longitude!;
  }
}
