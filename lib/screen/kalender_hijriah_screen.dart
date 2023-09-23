import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hijri_picker/hijri_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({Key? key}) : super(key: key);

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = HijriCalendar.now();
    final size = MediaQuery.of(context).size;
    DateTime selectedDatee = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kalender',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.height * 0.03,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: size.height * 0.385,
              padding: EdgeInsets.only(top: size.height * 0.03),
              child: SizedBox(
                width: size.width * 0.87,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: HijriMonthPicker(
                    lastDate: HijriCalendar()
                      ..hYear = 1500
                      ..hMonth = 9
                      ..hDay = 25,
                    firstDate: HijriCalendar()
                      ..hYear = 1438
                      ..hMonth = 12
                      ..hDay = 25,
                    selectedDate: selectedDate,
                    onChanged: (HijriCalendar value) {
                      // do something with the selected date
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: size.height * 0.5, // Adjust the height as needed
            padding: EdgeInsets.all(size.height * 0.03),
            child: SizedBox(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TableCalendar(
                  locale: 'id_ID',
                  daysOfWeekStyle: DaysOfWeekStyle(
                    dowTextFormatter: (date, locale) =>
                        DateFormat.E(locale).format(date)[0],
                  ),
                  shouldFillViewport: true,
                  focusedDay: selectedDatee,
                  firstDay: DateTime.utc(1900, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) {
                    // Ganti warna teks hari "today" menjadi putih di sini
                    return isSameDay(day, DateTime.now());
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: size.height * 0.02,
                    ),
                    weekendTextStyle: TextStyle(
                      fontSize: size.height * 0.02,
                    ),
                    outsideTextStyle: TextStyle(
                        fontSize: size.height * 0.02, color: Colors.grey),
                    defaultTextStyle: TextStyle(
                      fontSize: size.height * 0.02,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
