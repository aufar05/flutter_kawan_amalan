// ignore_for_file: use_key_in_widget_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:test1/screen/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test1/util/constants.dart';
import './screen/navigasi_screen.dart';
import './screen/utils.dart';
import './screen/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import './services/notification_services.dart';
import 'screen/auth2_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  requestNotificationPermission();
  NotificationService().initNotification();
  await _configureLocalTimeZone();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

Future<void> requestNotificationPermission() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  late Map<Permission, PermissionStatus?> statusess;

  if (androidInfo.version.sdkInt <= 32) {
    statusess = await [
      Permission.notification,
    ].request().then((statuses) =>
        {Permission.notification: statuses[Permission.notification]});
  } else {
    statusess = await [Permission.photos, Permission.notification]
        .request()
        .then((statuses) => {
              Permission.photos: statuses[Permission.photos],
              Permission.notification: statuses[Permission.notification]
            });
  }

  if (statusess[Permission.notification] == PermissionStatus.granted) {
    // notifikasi sudah diizinkan
    NotificationService();
  } else {
    // notifikasi belum diizinkan
    // Anda bisa menampilkan pesan kepada pengguna atau melakukan tindakan lainnya
  }
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // Inggris
          Locale('id', ''), // Indonesia
        ],
        scaffoldMessengerKey: Utils.messengerKey,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Kawan Amalan',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white38,
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.symmetric(
                vertical: defaultPadding * 1.2, horizontal: defaultPadding),
          ),
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const SplashScreen(),
      );
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!'));
            } else if (snapshot.hasData) {
              return const MyHomePage(
                index: 0,
              );
            } else {
              return const AuthScreen();
            }
          },
        ),
      );
}




// ignore: must_be_immutable



