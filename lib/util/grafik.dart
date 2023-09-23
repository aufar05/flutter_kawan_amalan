import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class AmalanChart {
  final String name;
  int count;
  final DateTime createdDate;

  AmalanChart(this.name, this.count, this.createdDate);
}

class GrafikCount extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  const GrafikCount(this.seriesList, {Key? key, required this.animate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: charts.BarChart(
        seriesList.cast<charts.Series<dynamic, String>>(),
        animate: animate,
        animationDuration: const Duration(milliseconds: 500),
        barGroupingType: charts.BarGroupingType.grouped,
        behaviors: [
          charts.ChartTitle('Grafik Amalan Per Minggu',
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea,
              titlePadding: 20,
              subTitle: ''),
          charts.ChartTitle(
            'Jumlah Amalan',
            behaviorPosition: charts.BehaviorPosition.start,
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea,
          ),
          charts.LinePointHighlighter(
            symbolRenderer: charts.CircleSymbolRenderer(),
            defaultRadiusPx: 4,
            dashPattern: const [2, 2],
            drawFollowLinesAcrossChart: true,
            showHorizontalFollowLine:
                charts.LinePointHighlighterFollowLineType.nearest,
            showVerticalFollowLine:
                charts.LinePointHighlighterFollowLineType.none,
          ),
        ],
      ),
    );
  }
}

class SunnahList extends StatefulWidget {
  final String uid;

  const SunnahList({Key? key, required this.uid}) : super(key: key);

  @override
  _SunnahListState createState() => _SunnahListState();
}

DateTime _getStartOfMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}

DateTime _getEndOfMonth() {
  final now = DateTime.now();
  final nextMonth = DateTime(now.year, now.month + 1, 1);
  final endOfMonth = nextMonth.subtract(const Duration(days: 1));
  return endOfMonth;
}

List<AmalanChart> _getWeeklyData(QuerySnapshot<Map<String, dynamic>> snapshot) {
  final weeklyData = <AmalanChart>[];
  final startOfMonth = _getStartOfMonth();
  final endOfMonth = _getEndOfMonth();
  // print('startOfMonth: $startOfMonth'); // mencetak nilai startOfMonth
  // print('endOfMonth: $endOfMonth'); // mencetak nilai endOfMonth
  // Menghitung jumlah minggu dalam bulan ini
  final daysInMonth = endOfMonth.day;

  var weeksInMonth =
      ((daysInMonth - (startOfMonth.weekday % 7)) / 7).ceil() + 1;

// Jika weeksInMonth lebih dari 5, kurangi 1
  if (weeksInMonth > 5) {
    weeksInMonth -= 1;
  }

  // Menginisialisasi data untuk setiap minggu
  for (var i = 0; i < weeksInMonth; i++) {
    final weekStart = startOfMonth.add(Duration(days: i * 7));
    weeklyData.add(AmalanChart('Minggu ${i + 1}', 0, weekStart));
  }

  // Menghitung jumlah amalan per minggu
  for (var doc in snapshot.docs) {
    final waktuDikerjakan = doc['waktuDikerjakan'] as List<dynamic>;
    for (var waktu in waktuDikerjakan) {
      if (waktu is String) {
        final createdDate = DateTime.parse(waktu);
        if (createdDate
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            createdDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          final weekNumber =
              _getWeekNumber(createdDate, startOfMonth, weeksInMonth);
          if (weekNumber != null) {
            weeklyData[weekNumber - 1].count += doc['count'] as int;
          }
        }
      } else if (waktu is Map<String, dynamic>) {
        final createdDate = DateTime.parse(waktu['createdDate'] as String);
        if (createdDate
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            createdDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          final weekNumber =
              _getWeekNumber(createdDate, startOfMonth, weeksInMonth);
          if (weekNumber != null) {
            weeklyData[weekNumber - 1].count += doc['count'] as int;
          }
        }
      }
    }
  }

  return weeklyData;
}

int? _getWeekNumber(DateTime date, DateTime startOfMonth, int weeksInMonth) {
  final daysSinceStartOfMonth = date.difference(startOfMonth).inDays;
  if (daysSinceStartOfMonth < 0 || daysSinceStartOfMonth >= weeksInMonth * 7) {
    return null; // handle dates outside of the current month
  }
  final weekNumber = (daysSinceStartOfMonth / 7).floor() + 1;
  if (weekNumber < 1 || weekNumber > weeksInMonth) {
    return null; // handle invalid week numbers
  }
  return weekNumber;
}

class _SunnahListState extends State<SunnahList> {
  String? _selectedAmalan;
  List<DropdownMenuItem<String>>? _dropdownMenuItems;

  List<charts.Series<AmalanChart, String>> _createSeries(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final weeklyData = _getWeeklyData(snapshot);

    // print('weeklyData: $weeklyData');

    return [
      charts.Series<AmalanChart, String>(
        id: 'Amalan',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (AmalanChart amalan, _) => amalan.name,
        measureFn: (AmalanChart amalan, _) => amalan.count,
        data: weeklyData
            .map((amalan) =>
                AmalanChart(amalan.name, amalan.count, amalan.createdDate))
            .toList(),
        labelAccessorFn: (AmalanChart amalan, _) => '${amalan.count}',
      ),
    ];
  }

  Future<List<DropdownMenuItem<String>>> _getAmalanItems() async {
    List<DropdownMenuItem<String>> items = [];
    final user = FirebaseAuth.instance.currentUser;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('sunnahList')
        .where('amalanId', isEqualTo: user!.uid)
        .orderBy('name')
        .get();
    Map<String, dynamic> map = {};
    for (var doc in snapshot.docs) {
      if (map[doc['name']] == null) {
        map[doc['name']] = doc.data();
      }
    }
    map.forEach((key, value) {
      items.add(
        DropdownMenuItem<String>(
          value: key,
          child: Text(key),
        ),
      );
    });
    if (items.isNotEmpty) {
      _selectedAmalan = items[0].value;
    } else {
      _selectedAmalan = 'Pilih Amalan';
    }
    return items;
  }

  @override
  void initState() {
    _dropdownMenuItems = [];
    _getAmalanItems().then((items) {
      setState(() {
        _dropdownMenuItems = items;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _dropdownMenuItems != null
              ? DropdownButton<String>(
                  value: _selectedAmalan,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAmalan = newValue;
                      // print('Selected amalan: $_selectedAmalan');
                    });
                  },
                  items: _dropdownMenuItems!,
                )
              : const CircularProgressIndicator(),
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('sunnahList')
              .where('isDone', isEqualTo: true)
              .where('amalanId', isEqualTo: widget.uid)
              .where('name', isEqualTo: _selectedAmalan)
              .where('lastDoneDate',
                  isGreaterThanOrEqualTo: _getStartOfMonth().toString())
              .where('lastDoneDate',
                  isLessThanOrEqualTo: _getEndOfMonth().toString())
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.docs.isNotEmpty) {
                List<charts.Series<AmalanChart, String>> series =
                    _createSeries(snapshot.data!);
                return GrafikCount(series, animate: true);
              } else {
                return Column(children: [
                  Lottie.asset(
                    'lib/images/grafikNotFound2.json',
                  ),
                  const Text('Grafik tidak ditemukan.'),
                ]);
              }
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Terjadi kesalahan.'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
  }
}
