import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../util/grafik.dart';

class LaporanAmalPage extends StatefulWidget {
  const LaporanAmalPage({Key? key}) : super(key: key);

  @override
  _LaporanAmalPageState createState() => _LaporanAmalPageState();
}

class _LaporanAmalPageState extends State<LaporanAmalPage> {
  final user = FirebaseAuth.instance.currentUser;
  String _username = '';

  int count = 0;

  late List<String> docIDs = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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

      return documents;
    } catch (e) {
      // print('Error: $e');
      return [];
    }
  }

  Future<List<DocumentSnapshot>> getAmalanShow() async {
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
    _loadUsername();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(224, 224, 224, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.25),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.elliptical(175, 35)),
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('lib/images/bgLaporan.png'),
                        fit: BoxFit.cover)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan Amalan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.height * 0.025,
                          ),
                        ),
                        SizedBox(height: size.height * 0.025),
                        Text(
                          _username.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              height: size.height * 0.8,
              child: Container(),
            ),
          ],
        ),
      ),
      body: SunnahList(
        uid: user!.uid,
      ),
    );
  }
}
