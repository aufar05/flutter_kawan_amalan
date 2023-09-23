// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:test1/util/emoticons.dart';
import 'package:test1/util/katalog_amalan.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? amalanCount;
  String _username = '';
  late List<String> docIDs = [];
  final user = FirebaseAuth.instance.currentUser;

  Future<List<DocumentSnapshot>> getAmalan() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('sunnahList')
          .where('amalanId', isEqualTo: user!.uid)
          .get();

      final List<DocumentSnapshot> documents = snapshot.docs.where((doc) {
        final Timestamp docStart = doc['start'];
        final Timestamp docEnd = doc['end'];
        final DateTime now = DateTime.now();
        final String amalanName = doc['name'];

        if (amalanName == 'Puasa Senin Kamis') {
          return (now.weekday == 1 || now.weekday == 4) &&
              docStart.toDate().isBefore(now) &&
              docEnd.toDate().isAfter(now);
        } else {
          return docStart.toDate().isBefore(now) &&
              docEnd.toDate().isAfter(now);
        }
      }).toList();

      // Hitung jumlah dokumen di dalam `documents`

      return documents;
    } catch (e) {
      // print('Error: $e');
      return [];
    }
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final username = doc['username'];
    // print('Username: $username');
    setState(() {
      _username = username;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.yMMMd().format(DateTime.now());
    final size = MediaQuery.of(context).size;
    void signOut() {
      FirebaseAuth.instance.signOut();
    }

    void _modalDeskripsi1(BuildContext context) {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.elliptical(100, 50))),
        context: context,
        builder: (_) {
          return SizedBox(
            height: size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.015),
                  child: Text(
                    'Puasa Senin Kamis',
                    style: TextStyle(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Image.asset(
                  'lib/images/puasa.png',
                  height: size.height * 0.2,
                  width: size.width * 0.5,
                ),
                SizedBox(height: size.height * 0.02),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: size.width * 0.025, right: size.width * 0.025),
                      child: Column(
                        children: [
                          Text(
                            'Puasa Senin Kamis merupakan puasa sunah yang diajarkan Rasulullah SAW untuk dilakukan setiap hari senin dan kamis',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            'Niat Puasa di hari Senin  :  ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            ' نَوَيْتُ صَوْمَ يَوْمَ اْلاِثْنَيْنِ سُنَّةً ِللهِ تَعَالَى ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'Nawaitu shouma yaumal itsnaini sunnatal lillaahi ta\'aalaa',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            'Niat Puasa di hari Kamis  :  ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'نَوَيْتُ صَوْمَ يَوْمَ الْخَمِيْسِ سُنَّةً ِللهِ تَعَالَى',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'Nawaitu shouma yaumal khomiisi sunnatal lillaahi ta\'aalaa',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '“Rasulullah shallallahu ‘alaihi wa sallam biasa menaruh pilihan berpuasa pada hari senin dan kamis.”',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '(HR. An Nasai no. 2362 dan Ibnu Majah no. 1739)',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: size.height * 0.02),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                RaisedButton(
                  child: const Text('Tutup'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }

    void _modalDeskripsi2(BuildContext context) {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.elliptical(100, 50))),
        context: context,
        builder: (_) {
          return SizedBox(
            height: size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.015),
                  child: Text(
                    'Sholat Dhuha',
                    style: TextStyle(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Image.asset(
                  'lib/images/sholatDhuha.png',
                  height: size.height * 0.2,
                  width: size.width * 0.5,
                ),
                SizedBox(height: size.height * 0.02),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Sholat dhuha adalah sholat sunah yang dilakukan setelah terbit matahari (sekitar 15 menit sesudah matahari terbit) sampai menjelang waktu zuhur(sekitar 15 menit sebelum dzuhur). ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            'Jumlah rakaat sholat dhuha adalah minimal 2 rakaat dan maksimal 12 rakaat',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            'Niat sholat dhuha adalah sebagai berikut :',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'اُصَلِّى سُنَّةَ الضَّحٰى رَكْعَتَيْنِ مُسْتَقْبِلَ الْقِبْلَةِ اَدَاءً ِللهِ تَعَالَى',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          Text(
                            'Ushalli Sunnatal Dhuha Rak\'ataini Lillaahi Ta\'alaa.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '“Allah Ta’ala berfirman: Wahai anak Adam, janganlah engkau tinggalkan empat raka’at shalat di awal siang (di waktu Dhuha). Maka itu akan mencukupimu di akhir siang”',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '(HR. Tirmidzi no. 475)',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: size.height * 0.02),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                RaisedButton(
                  child: const Text('Tutup'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }

    void _modalDeskripsi3(BuildContext context) {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.elliptical(100, 50))),
        context: context,
        builder: (_) {
          return SizedBox(
            height: size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.015),
                  child: Text(
                    'Shalat Rawatib',
                    style: TextStyle(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Image.asset(
                  'lib/images/rawatib2.png',
                  height: size.height * 0.2,
                  width: size.width * 0.5,
                ),
                SizedBox(height: size.height * 0.02),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(
                        children: [
                          const Text(
                            'Shalat Sunnah Rawatib adalah shalat sunah yang waktu pelaksanaannya  mengiringi shalat fardu . Shalat tersebut dilakukan sebelum atau sesudah shlat fardu.',
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'Niat Shalat Rawatib:',
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'Bacaan niat sholat sunah rawatib pada dasarnya tidak jauh berbeda dengan bacaan sholat fardu, tinggal menambahkan Qobliyatan Lillahi Ta’ala (jika dikerjakan sebelum sholat fardhu) di akhir niat atau Ba’diyatan Lillahi Ta’ala (jika dikerjakan sesudah sholat fardhu).',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          const Text(
                            '“Barangsiapa sehari semalam mengerjakan shalat 12 raka’at (sunnah rawatib), akan dibangunkan baginya rumah di surga, yaitu: 4 raka’at sebelum Zhuhur, 2 raka’at setelah Zhuhur, 2 raka’at setelah Maghrib, 2 raka’at setelah ‘Isya dan 2 raka’at sebelum Shubuh.” ',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '(HR. Tirmidzi no. 415 dan An Nasai no. 1794)',
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                RaisedButton(
                  child: const Text('Tutup'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }

    void _modalDeskripsi4(BuildContext context) {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.elliptical(100, 50))),
        context: context,
        builder: (_) {
          return SizedBox(
            height: size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.015),
                  child: Text(
                    'Shalat Tahajjud',
                    style: TextStyle(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Image.asset(
                  'lib/images/sholatTahajud.png',
                  height: size.height * 0.2,
                  width: size.width * 0.5,
                ),
                SizedBox(height: size.height * 0.02),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(
                        children: [
                          const Text(
                            'Shalat Tahajud adalah shalat sunah muakad yang didirikan pada malam hari atau malam menjelang pagi/ sepertiga malam setelah terjaga dari tidur.',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          const Text(
                            'Jumlah Rakaat shalat tahajud genap jika tanpa witir dan rakaat shalat tahajud minimal 2 rakaat',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          const Text(
                            'Niat Shalat Tahajud',
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'أُصَلِّيْ سُنَّةَ التَهَجُّدِ رَكْعَتَيْنِ لِلهِ تَعَالَى',
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'Ushalli sunnatat tahajjudi rak’ataini lillahi ta’ala',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          const Text(
                            '"Pada sebagian malam lakukanlah sholat tahajud sebagai (suatu ibadah) tambahan bagimu, mudah-mudahan Tuhanmu mengangkatmu ke tempat yang terpuji."',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '(QS Al-Isra: 79)',
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                RaisedButton(
                  child: const Text('Tutup'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }

    void _modalDeskripsi5(BuildContext context) {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.elliptical(100, 50))),
        context: context,
        builder: (_) {
          return SizedBox(
            height: size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.015),
                  child: Text(
                    'Dzikir Pagi Petang',
                    style: TextStyle(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Image.asset(
                  'lib/images/dzikir.png',
                  height: size.height * 0.2,
                  width: size.width * 0.5,
                ),
                SizedBox(height: size.height * 0.02),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(
                        children: [
                          Text(
                            'Dzikir pagi dan petang adalah sebagai amalan sunnah yang ringan dilakukan.Dzikir pagi petang dapat dilakukan dengan membaca Al-Ma\'tsurat.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '“Hai orang-orang yang beriman, berzikirlah (dengan menyebut nama) Allah, zikir yang sebanyak-banyaknya. Dan bertasbihlah kepada-Nya di waktu pagi dan petang."',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '(QS Al-Ahzab: 41-42)',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: size.height * 0.02),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                RaisedButton(
                  child: const Text('Tutup'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }

    void _modalDeskripsi6(BuildContext context) {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.elliptical(100, 50))),
        context: context,
        builder: (_) {
          return SizedBox(
            height: size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.015),
                  child: Text(
                    'Baca Al-Quran',
                    style: TextStyle(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Image.asset(
                  'lib/images/bacaAl-Quran.png',
                  height: size.height * 0.2,
                  width: size.width * 0.5,
                ),
                SizedBox(height: size.height * 0.02),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: Column(
                    children: [
                      const Text(
                        '“Bacalah Al Qur`an, karena ia akan datang memberi syafaat kepada para pembacanya pada hari kiamat nanti”',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Text(
                        '(HR. Muslim: 1337)',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.025),
                RaisedButton(
                  child: const Text('Tutup'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff203E58),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assalamualaikum , $_username',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * 0.02,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            date,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 214, 251, 255),
                                fontSize: size.height * 0.017),
                          )
                        ],
                      ),
                      //profil
                      InkWell(
                        onTap: signOut,
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 24, 81, 130),
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  //progres hari ini
                  Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 24, 81, 130),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Progres Amalan hari ini',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FutureBuilder<List<DocumentSnapshot>>(
                            future: getAmalan(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<DocumentSnapshot> documents =
                                    snapshot.data!;
                                int amalanCount = documents.length;

                                double percent = 0;
                                if (amalanCount > 0) {
                                  int doneCount = 0;
                                  for (var document in documents) {
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;
                                    if (data.containsKey('lastDoneDate')) {
                                      DateTime lastDoneDate =
                                          DateTime.parse(data['lastDoneDate']);
                                      if (lastDoneDate.year ==
                                              DateTime.now().year &&
                                          lastDoneDate.month ==
                                              DateTime.now().month &&
                                          lastDoneDate.day ==
                                              DateTime.now().day) {
                                        doneCount++;
                                      }
                                    }
                                  }
                                  percent = doneCount / amalanCount;
                                }

                                return LinearPercentIndicator(
                                  width: 180.0,
                                  lineHeight: 14.0,
                                  percent: percent,
                                  center: Text(
                                    "${(percent * 100).toStringAsFixed(1)}%",
                                    style:
                                        TextStyle(fontSize: size.width * 0.03),
                                  ),
                                  barRadius: const Radius.circular(10),
                                  backgroundColor: Colors.grey,
                                  progressColor:
                                      const Color.fromARGB(104, 82, 255, 29),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.025,
                  ),
                  Text(
                    'Bagaimana kabarmu hari ni ?',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.02),
                  ), // nanya kabar
                  SizedBox(
                    height: size.height * 0.025,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmoticonSelector(),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.025,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                child: Container(
                  padding: EdgeInsets.all(size.height * 0.015),
                  color: const Color.fromRGBO(224, 224, 224, 1),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Amalan Sunah',
                          style: TextStyle(
                              fontSize: size.height * 0.03,
                              fontWeight: FontWeight.bold),
                        ),
                        //katalog amalan sunnah
                        SizedBox(height: size.height * 0.025),

                        Expanded(
                          child: ListView(
                            children: [
                              InkWell(
                                onTap: () => _modalDeskripsi1(context),
                                child: KatalogAmalan(
                                  image: Image.asset(
                                    'lib/icons/fasting2.png',
                                    height: 35,
                                    width: 35,
                                    color: Colors.white,
                                  ),
                                  judul: 'Puasa Senin Kamis',
                                ),
                              ),
                              InkWell(
                                onTap: () => _modalDeskripsi2(context),
                                child: KatalogAmalan(
                                  image: Image.asset(
                                    'lib/icons/dhuha.png',
                                    height: 35,
                                    width: 35,
                                    color: Colors.white,
                                  ),
                                  judul: 'Shalat Dhuha',
                                ),
                              ),
                              InkWell(
                                onTap: () => _modalDeskripsi3(context),
                                child: KatalogAmalan(
                                  image: Image.asset(
                                    'lib/icons/rawatib.png',
                                    height: 35,
                                    width: 35,
                                    color: Colors.white,
                                  ),
                                  judul: 'Shalat Rawatib',
                                ),
                              ),
                              InkWell(
                                onTap: () => _modalDeskripsi4(context),
                                child: KatalogAmalan(
                                  image: Image.asset(
                                    'lib/icons/tahajud.png',
                                    height: 35,
                                    width: 35,
                                    color: Colors.white,
                                  ),
                                  judul: 'Shalat Tahajjud',
                                ),
                              ),
                              InkWell(
                                onTap: () => _modalDeskripsi5(context),
                                child: KatalogAmalan(
                                  image: Image.asset(
                                    'lib/icons/tasbih.png',
                                    height: 35,
                                    width: 35,
                                    color: Colors.white,
                                  ),
                                  judul: 'Dzikir Pagi Petang',
                                ),
                              ),
                              InkWell(
                                onTap: () => _modalDeskripsi6(context),
                                child: KatalogAmalan(
                                  image: Image.asset(
                                    'lib/icons/quran.png',
                                    height: 35,
                                    width: 35,
                                    color: Colors.white,
                                  ),
                                  judul: 'Baca Al-Quran',
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
