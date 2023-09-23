import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:test1/screen/navigasi_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AddSunnahPage extends StatefulWidget {
  const AddSunnahPage({Key? key}) : super(key: key);

  @override
  _AddSunnahPageState createState() => _AddSunnahPageState();
}

class _AddSunnahPageState extends State<AddSunnahPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void previousPage() {
    setState(() {
      // Do any necessary state updates here
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  final List<String> _sunnahList = [
    'Puasa Senin Kamis',
    'Puasa Ayyamul Bidh',
    'Puasa Daud',
    'Shalat Dhuha',
    'Shalat Rawatib',
    'Shalat Tahajud',
    'Dzikir Pagi Petang',
    'Membaca Al-Quran',
  ];

  final Map<String, String> _satuanList = {
    'Puasa Senin Kamis': 'Kali',
    'Puasa Ayyamul Bidh': 'Kali',
    'Puasa Daud': 'Kali',
    'Shalat Dhuha': 'Rakaat',
    'Shalat Rawatib': 'Rakaat',
    'Shalat Tahajud': 'Rakaat',
    'Dzikir Pagi Petang': 'Kali',
    'Membaca Al-Quran': 'Halaman',
  };

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(hours: 24 * 3)),
  );

  DateTime _calculateMiddleOfHijriMonth() {
    // Get the current Hijri month and year
    HijriCalendar now = HijriCalendar.now();
    int month = now.hMonth;
    int year = now.hYear;
    var gDate = HijriCalendar();

    // Get the number of days in the current Hijri month
    int daysInMonth = now.lengthOfMonth;

    // Calculate the middle day of the current Hijri month
    int middleDay = (daysInMonth / 2).ceil();

    // Create a new HijriCalendar object representing the middle day of the current Hijri month

    // Convert the HijriCalendar object to a DateTime object in the local timezone
    DateTime middleDateTime = gDate.hijriToGregorian(year, month, middleDay);

    return middleDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Tambah Amalan Sunah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: size.height * 0.5,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: _sunnahList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_sunnahList[index]),
                    trailing: Lottie.asset(
                      'lib/icons/addButton.json',
                    ),
                    onTap: () {
                      _showAddDialog(context, _sunnahList[index],
                          _satuanList[_sunnahList[index]]!);
                    },
                  ),
                );
              },
            ),
          ),
          Lottie.asset(
            'lib/images/notFound.json',
            width: size.width * 0.3,
            height: size.height * 0.2,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Jika tidak menemukan amalan yang ingin di kerjakan bisa menekan tombol tambah di pojok kanan atas',
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context,
      [String? sunnahName, String? satuan, int? jumlah]) {
    TextEditingController namaAmalan_controller = TextEditingController();
    TextEditingController jumlahAmalan_controller = TextEditingController();
    DateTimeRange newDateRange = dateRange;
    int _selectedOptionIndex = 0;
    // ignore: unused_local_variable
    int _selectedOptionIndex2 = 0;
    DateTime middleOfHijriMonth = _calculateMiddleOfHijriMonth();
    DateTimeRange dateRange2 = DateTimeRange(
      start: middleOfHijriMonth.subtract(const Duration(hours: 24 * 2)),
      end: middleOfHijriMonth
          .add(const Duration(hours: 23, minutes: 59, seconds: 59)),
    );
    DateTimeRange newDateRange2 = dateRange2;

    FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
    CollectionReference sunnahCollection =
        firestoreInstance.collection('sunnahList');

    if (sunnahName == 'Puasa Senin Kamis' ||
        sunnahName == 'Puasa Ayyamul Bidh' ||
        sunnahName == 'Puasa Daud' ||
        sunnahName == 'Dzikir Pagi Petang') {
      jumlahAmalan_controller.text = '1';
    }
    final size = MediaQuery.of(context).size;
    final Uri _url = Uri.parse(
        'https://www.portalamanah.com/artikel/pr-3302909423/50-amalan-sunah-sehari-hari');
    Future<void> _launchUrl() async {
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: sunnahName == null
                ? const Text('Tambah Amalan Baru')
                : Text('Tambah $sunnahName'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sunnahName == null)
                    TextField(
                      controller: namaAmalan_controller,
                      decoration:
                          const InputDecoration(labelText: 'Nama Amalan'),
                    ),
                  if (sunnahName != 'Shalat Rawatib' &&
                      sunnahName != 'Shalat Tahajud' &&
                      sunnahName != 'Rawatib Sebelum Subuh' &&
                      sunnahName != 'Rawatib Sebelum Dzuhur' &&
                      sunnahName != 'Rawatib Setelah Dzuhur' &&
                      sunnahName != 'Rawatib Setelah Maghrib' &&
                      sunnahName != 'Rawatib Setelah Isya' &&
                      sunnahName != 'Puasa Senin Kamis' &&
                      sunnahName != 'Puasa Ayyamul Bidh' &&
                      sunnahName != 'Puasa Daud' &&
                      sunnahName != 'Dzikir Pagi Petang')
                    TextField(
                      controller:
                          jumlahAmalan_controller, // tambahkan controller untuk field amount
                      decoration: InputDecoration(
                          labelText: 'Jumlah ${satuan ?? "Kali"} / Hari '),
                    ),
                  if (sunnahName == 'Rawatib Sebelum Subuh' ||
                      sunnahName == 'Rawatib Sebelum Dzuhur' ||
                      sunnahName == 'Rawatib Setelah Dzuhur' ||
                      sunnahName == 'Rawatib Setelah Maghrib' ||
                      sunnahName == 'Rawatib Setelah Isya')
                    TextField(
                      controller: jumlahAmalan_controller,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Jumlah ${satuan ?? "Kali"} / Hari ',
                        suffixText: 'Tidak Bisa Diubah',
                      ),
                    ),
                  if (sunnahName == 'Shalat Rawatib')
                    DropdownButton<int>(
                      value: _selectedOptionIndex,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOptionIndex = value!;
                          switch (value) {
                            case 0:
                              sunnahName = 'Rawatib Sebelum Subuh';
                              jumlahAmalan_controller.text = '2';

                              break;
                            case 1:
                              sunnahName = 'Rawatib Sebelum Dzuhur';
                              jumlahAmalan_controller.text = '4';
                              break;
                            case 2:
                              sunnahName = 'Rawatib Setelah Dzuhur';
                              jumlahAmalan_controller.text = '2';
                              break;
                            case 3:
                              sunnahName = 'Rawatib Setelah Maghrib';
                              jumlahAmalan_controller.text = '2';
                              break;
                            case 4:
                              sunnahName = 'Rawatib Setelah Isya';
                              jumlahAmalan_controller.text = '2';
                              break;
                          }
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Sebelum Subuh'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Sebelum Dzuhur'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Setelah Dzuhur'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Setelah Maghrib'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('Setelah Isya'),
                        ),
                      ],
                    ),
                  if (sunnahName == 'Shalat Tahajud')
                    DropdownButton<int>(
                      value: _selectedOptionIndex,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedOptionIndex = value!;
                          switch (value) {
                            case 0:
                              sunnahName = 'Shalat Tahajud ';

                              break;
                            case 1:
                              sunnahName = 'Shalat Tahajud dengan witir';

                              break;
                          }
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Tanpa Witir'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Dengan Witir'),
                        ),
                      ],
                    ),
                  if (sunnahName == 'Puasa Senin Kamis' ||
                      sunnahName == 'Puasa Ayyamul Bidh' ||
                      sunnahName == 'Puasa Daud' ||
                      sunnahName == 'Dzikir Pagi Petang')
                    TextField(
                      controller: jumlahAmalan_controller,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Jumlah ${satuan ?? "Kali"} / Hari ',
                        suffixText: 'Tidak Bisa Diubah',
                      ),
                    ),
                  if (sunnahName != 'Puasa Ayyamul Bidh')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text(
                                '${newDateRange.start.day}/${newDateRange.start.month}/${newDateRange.start.year}'),
                            onPressed: () async {
                              DateTime? selectedDate = await showDatePicker(
                                locale: const Locale('in'),
                                context: context,
                                initialDate: newDateRange.start,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  newDateRange = DateTimeRange(
                                      start: selectedDate,
                                      end: newDateRange.end);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.black),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: Text(
                                '${newDateRange.end.day}/${newDateRange.end.month}/${newDateRange.end.year}'),
                            onPressed: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: newDateRange.end,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  newDateRange = DateTimeRange(
                                      start: newDateRange.start,
                                      end: selectedDate);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  if (sunnahName == 'Puasa Ayyamul Bidh')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text(
                              '${newDateRange2.start.day}/${newDateRange2.start.month}/${newDateRange2.start.year}',
                            ),
                            onPressed: () async {
                              // ...
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.black),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: Text(
                              '${newDateRange2.end.day}/${newDateRange2.end.month}/${newDateRange2.end.year}',
                            ),
                            onPressed: () async {
                              // ...
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  SizedBox(height: size.height * 0.02),
                  if (sunnahName == null)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ElevatedButton(
                                onPressed: _launchUrl,
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: EdgeInsets.zero,
                                  primary: Colors.transparent,
                                  elevation: 0,
                                ),
                                child: Container(),
                              ),
                            ),
                            const Positioned.fill(
                              child: Icon(
                                Icons.info,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final user = _auth.currentUser;
                  String newSunnahName =
                      sunnahName ?? namaAmalan_controller.text.trim();

                  // check if sunnah with the same name and overlapping date range exists
                  QuerySnapshot overlappingSunnahs = await sunnahCollection
                      .where('name', isEqualTo: newSunnahName)
                      .where('amalanId', isEqualTo: user!.uid)
                      .where('start',
                          isLessThanOrEqualTo:
                              Timestamp.fromDate(newDateRange.end))
                      .get();

                  if (overlappingSunnahs.docs.isNotEmpty) {
                    // if there is overlapping sunnah, check if end time has passed
                    DateTime lastEndTime =
                        overlappingSunnahs.docs.last.get('end').toDate();
                    if (newDateRange.start.isBefore(lastEndTime)) {
                      // show error dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Gagal Menambahkan Amalan Baru'),
                          content: const Text(
                            'Anda tidak dapat menambahkan amalan dengan nama yang sama dan rentang tanggal yang tumpang tindih, kecuali rentang tanggal yang tumpang tindih sudah berakhir',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }

                  if (sunnahName == 'Shalat Dhuha' &&
                      int.tryParse(jumlahAmalan_controller.text)! % 2 != 0) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Jumlah rakaat harus genap!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  if (sunnahName == 'Shalat Tahajud ' &&
                      int.tryParse(jumlahAmalan_controller.text)! % 2 != 0) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Jumlah rakaat harus genap!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  if (sunnahName == 'Shalat Tahajud dengan witir') {
                    int jumlahRakaat =
                        int.tryParse(jumlahAmalan_controller.text) ?? 0;
                    if (jumlahRakaat <= 1 || jumlahRakaat % 2 == 0) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'Jumlah rakaat harus ganjil dan lebih dari 1!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }

                  bool isDone = true;
                  Timestamp startDate = Timestamp.fromDate(newDateRange.start);
                  Timestamp endDate = Timestamp.fromDate(newDateRange.end);
                  if (newSunnahName == 'Puasa Ayyamul Bidh') {
                    startDate = Timestamp.fromDate(newDateRange2.start);
                    endDate = Timestamp.fromDate(newDateRange2.end);
                  }
                  await FirebaseFirestore.instance
                      .collection('sunnahList')
                      .add({
                    'name': newSunnahName,
                    'jumlah': int.parse(jumlahAmalan_controller.text),
                    'unit': satuan ?? 'Kali',
                    'start': startDate,
                    'end': endDate,
                    'isDone': !isDone,
                    'amalanId': user.uid,
                    'status_notifikasi': false,
                    'waktuDikerjakan': {
                      'createdDate': FieldValue.serverTimestamp()
                          .toString()
                          .substring(0, 10),
                    }
                  });
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Data Berhasil Disimpan'),
                      content: const Text('Target Amalan Berhasil Dibuat'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyHomePage(
                                        index: 2,
                                      )),
                            );
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }
}
