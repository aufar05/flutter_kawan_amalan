import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:test1/screen/amalans_sunnah_screen.dart';
import 'package:test1/screen/laporan_amal_screen.dart';
import 'home_page.dart';
import '../screen/adzan_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyHomePage extends StatefulWidget {
  final int index;

  const MyHomePage({Key? key, this.index = 0}) : super(key: key);
  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  final screens = [
    const HomeScreen(),
    const WaktuAdzan(),
    const AmalanSunnahPage(),
    const LaporanAmalPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(
        Icons.home_rounded,
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(
          FontAwesomeIcons.mosque,
          size: 16,
        ),
      ),
      const Icon(
        Icons.checklist_rounded,
      ),
      const Icon(
        Icons.analytics_rounded,
      ),
    ];

    final _size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: screens[index],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        child: CurvedNavigationBar(
            height: _size.height * 0.08,
            backgroundColor: const Color.fromRGBO(224, 224, 224, 1),
            buttonBackgroundColor: const Color.fromARGB(255, 33, 93, 97),
            color: const Color.fromARGB(255, 64, 159, 166),
            items: items,
            index: index,
            onTap: (index) => setState(() => this.index = index)),
      ),
    );
  }
}
