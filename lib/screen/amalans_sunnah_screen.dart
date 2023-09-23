import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:test1/util/amalan.dart';
import '../widgets/tambahAmalan.dart';
import '../services/notification_services.dart';
import 'kalender_hijriah_screen.dart';

class AmalanSunnahPage extends StatefulWidget {
  const AmalanSunnahPage({Key? key}) : super(key: key);

  @override
  _AmalanSunnahPageState createState() => _AmalanSunnahPageState();
}

class _AmalanSunnahPageState extends State<AmalanSunnahPage> {
  final user = FirebaseAuth.instance.currentUser;
  String _username = '';
  bool _isLoading = true;

  int count = 0;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

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
        } else if (amalanName == 'Puasa Daud') {
          return now.day % 2 != 0 &&
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
        } else if (amalanName == 'Puasa Daud') {
          return now.day % 2 != 0 &&
              docStart.toDate().isBefore(now) &&
              docEnd.toDate().isAfter(now);
        } else {
          return docStart.toDate().isBefore(now) &&
              docEnd.toDate().isAfter(now);
        }
      }).toList();

      // Memperbarui status_notifikasi menjadi false untuk dokumen yang tidak ditampilkan
      final List<String> notShownDocsIds = snapshot.docs
          .map((doc) => doc.id)
          .where((docId) => !documents.any((doc) => doc.id == docId))
          .toList();
      for (final docId in notShownDocsIds) {
        await FirebaseFirestore.instance
            .collection('sunnahList')
            .doc(docId)
            .update({
          'status_notifikasi': false,
        });
        int id = docId.hashCode;
        await NotificationService().cancelNotification(id);
        debugPrint('Notification cancelled for with id $id');
      }

      return documents;
    } catch (e) {
      // print('Error: $e');
      return [];
    }
  }

  Future<void> getAmalanId() async {
    try {
      List<DocumentSnapshot> documents = await getAmalan();

      for (var document in documents) {
        docIDs.add(document.id);
      }

      // print('docIDs: $docIDs');
    } catch (e) {
      // print('Error: $e');
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

  // Future<void> checkUserId() async {
  //   final user = FirebaseAuth.instance.currentUser;

  //   final userId = user!.uid;
  //   final docRef = FirebaseFirestore.instance.collection("users").doc(userId);
  //   final docSnapshot = await docRef.get();
  //   if (docSnapshot.exists) {
  //     final data = docSnapshot.data();
  //     final userIdFromDoc = data!['userId'];
  //     print("User document data: $data");
  //     print("userId from document: $userIdFromDoc");
  //   } else {
  //     print("No such document!");
  //   }
  // }

  // Future<void> checkJumlahDone() async {
  //   int doneCount = 0;
  //   int notDoneCount = 0;
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance
  //       .collection('sunnahList')
  //       .where('amalanId', isEqualTo: user!.uid)
  //       .get();
  //   List<QueryDocumentSnapshot> docs = snapshot.docs;

  //   // Mengecek jumlah amalan yang sudah dikerjakan pada hari ini
  //   for (int i = 0; i < docs.length; i++) {
  //     Map<String, dynamic> data = docs[i].data() as Map<String, dynamic>;
  //     if (data.containsKey('lastDoneDate')) {
  //       DateTime lastDoneDate = DateTime.parse(data['lastDoneDate']);
  //       if (lastDoneDate.year == DateTime.now().year &&
  //           lastDoneDate.month == DateTime.now().month &&
  //           lastDoneDate.day == DateTime.now().day) {
  //         doneCount++;
  //       } else {
  //         notDoneCount++;
  //       }
  //     } else {
  //       notDoneCount++;
  //     }
  //   }

  //   // print('Jumlah amalan yang sudah dikerjakan hari ini: $doneCount');
  //   // print('Jumlah amalan yang belum dikerjakan hari ini: $notDoneCount');
  // }

  @override
  void initState() {
    // checkUserId();
    _loadUsername();
    initializeDateFormatting('id_ID', null);
    // checkJumlahDone();
    getAmalanId().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();

    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    // _calendarFormat = CalendarFormat.week;
    // _rangeSelectionMode = RangeSelectionMode.toggledOff;
    // _events = {};
  }

  @override
  void dispose() {
    // Memanggil method cancelNotification() dari NotificationService
    // NotificationService().cancelNotification(id);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String date = DateFormat.yMMMM("id_ID").format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color.fromRGBO(224, 224, 224, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.25),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.elliptical(100, 50)),
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('lib/images/bgJadwalAmalan.png'),
                        fit: BoxFit.cover)),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.height * 0.035),
                            Text(
                              'Amalan Sunah',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * 0.025,
                              ),
                            ),
                            SizedBox(height: size.height * 0.025),
                            Text(
                              _username.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.height * 0.02),
                            ),
                            SizedBox(height: size.height * 0.01),
                            Text(
                              'Target Amalan hari ini sebanyak',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.height * 0.018),
                            ),
                            SizedBox(height: size.height * 0.02),
                            Padding(
                              padding: EdgeInsets.only(left: size.width * 0.25),
                              child: Text(
                                '${docIDs.length}',
                                style: TextStyle(
                                  fontSize: size.height * 0.045,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : docIDs.isEmpty
              ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(size.height * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: size.width * 0.1),
                              child: Text(
                                date,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: size.height * 0.022),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HijriCalendarScreen()),
                              );
                            },
                            child: Material(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: EdgeInsets.all(size.height * 0.01),
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  color: Colors.white,
                                  size: size.height * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TableCalendar(
                      headerVisible: false,
                      locale: 'id_ID',
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                      ),
                      headerStyle: HeaderStyle(
                          titleCentered: true,
                          headerPadding: EdgeInsets.all(size.height * 0.03),
                          formatButtonVisible: false,
                          leftChevronVisible: false,
                          rightChevronVisible: false),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, events) => Container(
                          margin: EdgeInsets.all(size.width * 0.01),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * 0.02),
                          ),
                        ),
                      ),
                      calendarFormat: CalendarFormat.week,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      firstDay: DateTime.now()
                          .subtract(Duration(days: DateTime.now().weekday - 1)),
                      lastDay: DateTime.now().add(Duration(
                          days: DateTime.daysPerWeek - DateTime.now().weekday)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDay),
                      // onDaySelected: (selectedDay, focusedDay) {
                      //   // lakukan sesuatu ketika pengguna memilih suatu hari
                      //   setState(() {
                      //     _selectedDay = selectedDay;
                      //     _focusedDay = focusedDay;
                      //   });
                      // },
                    ),
                    Lottie.asset(
                      'lib/images/targetKosong.json',
                      width: size.width * 0.3,
                      height: size.height * 0.2,
                    ),
                    Center(
                        child: Text(
                      'Sepertinya Anda Belum Menargetkan Amalan',
                      style: TextStyle(fontSize: size.height * 0.02),
                    )),
                    Container(
                      padding: EdgeInsets.all(size.height * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddSunnahPage()),
                              );
                            },
                            child: const Text('Buat Amalan Baru'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(size.height * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: size.width * 0.1),
                              child: Text(
                                date,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: size.height * 0.022),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HijriCalendarScreen()),
                              );
                            },
                            child: Material(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: EdgeInsets.all(size.height * 0.01),
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  color: Colors.white,
                                  size: size.height * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TableCalendar(
                      headerVisible: false,
                      locale: 'id_ID',
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                      ),
                      headerStyle: HeaderStyle(
                          titleCentered: true,
                          headerPadding: EdgeInsets.all(size.height * 0.03),
                          formatButtonVisible: false,
                          leftChevronVisible: false,
                          rightChevronVisible: false),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, events) => Container(
                          margin: EdgeInsets.all(size.width * 0.01),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * 0.02),
                          ),
                        ),
                      ),
                      calendarFormat: CalendarFormat.week,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      firstDay: DateTime.now()
                          .subtract(Duration(days: DateTime.now().weekday - 1)),
                      lastDay: DateTime.now().add(Duration(
                          days: DateTime.daysPerWeek - DateTime.now().weekday)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDay),
                      // onDaySelected: (selectedDay, focusedDay) {
                      //   // lakukan sesuatu ketika pengguna memilih suatu hari
                      //   setState(() {
                      //     _selectedDay = selectedDay;
                      //     _focusedDay = focusedDay;
                      //   });
                      // },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FutureBuilder<List<DocumentSnapshot>>(
                        future: getAmalanShow(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              List<DocumentSnapshot> docs = snapshot.data!;
                              return ListView.builder(
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic>? data = docs[index]
                                      .data() as Map<String, dynamic>?;
                                  bool isDone = data?['isDone'] ?? false;
                                  String lastDoneDate =
                                      data?['lastDoneDate'] ?? '';

                                  // Check if the last done date is today
                                  if (lastDoneDate ==
                                      DateTime.now()
                                          .toString()
                                          .substring(0, 10)) {
                                    isDone = true;
                                  } else {
                                    isDone = false;
                                  }

                                  return Card(
                                    child: ListTile(
                                      title: GetAmalan(
                                        documentId: docs[index].id,
                                        uid: user!.uid,
                                      ),
                                      subtitle: GetJumlahAmalan(
                                        documentId: docs[index].id,
                                        uid: user!.uid,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              String docID = docIDs[index];
                                              String namaaAmalan =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('sunnahList')
                                                      .doc(docID)
                                                      .get()
                                                      .then((snapshot) {
                                                Map<String, dynamic> data =
                                                    snapshot.data()
                                                        as Map<String, dynamic>;
                                                if (data['amalanId'] ==
                                                    user!.uid) {
                                                  return data['name'];
                                                } else {
                                                  return 'Access denied';
                                                }
                                              });
                                              bool statusNotifikasi =
                                                  (docs[index].data() as Map<
                                                          String, dynamic>)[
                                                      'status_notifikasi'];
                                              if (!statusNotifikasi) {
                                                TimeOfDay? selectedTime =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                );
                                                if (selectedTime != null) {
                                                  int hour = selectedTime.hour;
                                                  int minute =
                                                      selectedTime.minute;

                                                  if (namaaAmalan ==
                                                          'Shalat Dhuha' &&
                                                      (hour < 7 || hour > 11)) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Error'),
                                                          content: const Text(
                                                              'Sholat Dhuha Hanya dalam waktu setelah matahari terbit dan sebelum waktu dzuhur sekitar  7 pagi - 11 pagi'),
                                                          actions: [
                                                            FlatButton(
                                                              child: const Text(
                                                                  'OK'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                    return;
                                                  }
                                                  if ((namaaAmalan ==
                                                              'Shalat Tahajud dengan witir' ||
                                                          namaaAmalan ==
                                                              'Shalat Tahajud ') &&
                                                      (hour < 21 || hour > 4)) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Error'),
                                                          content: const Text(
                                                              'Sholat Tahajud Hanya dalam waktu setelah isya sampai sebelum subuh sekitar  9 malam - 4 pagi'),
                                                          actions: [
                                                            FlatButton(
                                                              child: const Text(
                                                                  'OK'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                    return;
                                                  }
                                                  String docID = docIDs[index];
                                                  String namaAmalan =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'sunnahList')
                                                          .doc(docID)
                                                          .get()
                                                          .then((snapshot) {
                                                    Map<String, dynamic> data =
                                                        snapshot.data() as Map<
                                                            String, dynamic>;
                                                    if (data['amalanId'] ==
                                                        user!.uid) {
                                                      return data['name'];
                                                    } else {
                                                      return 'Access denied';
                                                    }
                                                  });
                                                  // Memperbarui dokumen dengan status notifikasi yang baru
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('sunnahList')
                                                      .doc(docs[index].id)
                                                      .update({
                                                    'status_notifikasi': true,
                                                  });
                                                  int id = docID.hashCode;
                                                  await NotificationService()
                                                      .notifikasiAmalan(
                                                    id,
                                                    hour,
                                                    minute,
                                                    'Notifikasi Amalan $namaAmalan',
                                                    'Jangan lupa kerjakan amalan $namaAmalan',
                                                  );
                                                  // print(
                                                  //     'Notifikasi Amalan $namaAmalan dengan ID $docIDs[index].length');
                                                  // debugPrint(
                                                  //     'Selected time: $hour:$minute');
                                                }
                                              } else {
                                                String docID = docIDs[index];
                                                // Memperbarui dokumen dengan status notifikasi yang baru
                                                await FirebaseFirestore.instance
                                                    .collection('sunnahList')
                                                    .doc(docs[index].id)
                                                    .update({
                                                  'status_notifikasi':
                                                      false, // mengubah nilai status_notifikasi menjadi false
                                                });
                                                int id = docID.hashCode;
                                                await NotificationService()
                                                    .cancelNotification(id);
                                                debugPrint(
                                                    'Notification cancelled for with id $id');
                                              }
                                              setState(() {});
                                            },
                                            child: Icon(
                                              (docs[index].data() as Map<String,
                                                          dynamic>)[
                                                      'status_notifikasi']
                                                  ? Icons.notifications_active
                                                  : Icons.notifications_off,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          Checkbox(
                                            value: isDone,
                                            onChanged: isDone
                                                ? null
                                                : (value) async {
                                                    // Show confirmation dialog
                                                    bool isConfirmed =
                                                        await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              "Apakah Anda sudah mengerjakan amalan ini?"),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: const Text(
                                                                  "Belum"),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  "Sudah"),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );

                                                    if (isConfirmed) {
                                                      // Get the document reference
                                                      final docRef =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'sunnahList')
                                                              .doc(docs[index]
                                                                  .id);

                                                      // Get the current document snapshot
                                                      final docSnapshot =
                                                          await docRef.get();
                                                      final docData =
                                                          docSnapshot.data()
                                                              as Map<String,
                                                                  dynamic>;

                                                      // Get the current count value from the database
                                                      final currentCount =
                                                          docData['count']
                                                              as int?;

                                                      // Update isDone and lastDoneDate value in the database
                                                      await docRef.update({
                                                        'isDone': !isDone,
                                                        'lastDoneDate':
                                                            DateTime.now()
                                                                .toString()
                                                                .substring(
                                                                    0, 10),
                                                        'count': 1
                                                      });

                                                      await docRef.update({
                                                        'waktuDikerjakan':
                                                            FieldValue
                                                                .arrayUnion([
                                                          {
                                                            'createdDate':
                                                                DateTime.now()
                                                                    .toString()
                                                                    .substring(
                                                                        0, 10),
                                                          }
                                                        ])
                                                      });

                                                      // Update the count state
                                                      setState(() {
                                                        count = currentCount !=
                                                                null
                                                            ? currentCount + 1
                                                            : 1;
                                                        // print(
                                                        //     'New count: $count');
                                                      });
                                                    }

                                                    // Set the isDone state
                                                    setState(() {
                                                      isDone = true;
                                                    });
                                                  },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Text('Tidak ada data');
                            }
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddSunnahPage()),
                                );
                              },
                              child: const Text('Tambah Amalan Sunah '),
                            ),
                            // ElevatedButton(
                            //     onPressed: () async {
                            //       await NotificationService()
                            //           .checkPendingNotificationRequests(
                            //               context);
                            //       ;
                            //     },
                            //     child: Text('CheckNotifikasi')),
                            // ElevatedButton(
                            //     onPressed: () async {
                            //       await NotificationService()
                            //           .cancelAllNotifications();
                            //     },
                            //     child: Text('Hapus Semua Notifikasi')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
