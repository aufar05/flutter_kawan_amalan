import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AmalanProvider extends ChangeNotifier {
  List<DocumentSnapshot>? _documents;
  int? _amalanCount;

  Future<void> getAmalanData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('sunnahList')
          .where('amalanId', isEqualTo: user!.uid)
          .get();

      _documents = snapshot.docs.where((doc) {
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

      _amalanCount = _documents!.length;

      notifyListeners();
    } catch (e) {
      Text('Error: $e');
    }
  }

  List<DocumentSnapshot>? get documents => _documents;
  int? get amalanCount => _amalanCount;
}
