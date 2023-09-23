import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetAmalan extends StatelessWidget {
  final String documentId;
  final String uid;
  const GetAmalan({Key? key, required this.documentId, required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference amalan =
        FirebaseFirestore.instance.collection('sunnahList');

    return FutureBuilder<DocumentSnapshot>(
        future: amalan.doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            if (data['amalanId'] == uid) {
              return Text('${data['name']}');
            } else {
              return const Text('Access denied');
            }
          }
          return const Text('Loading');
        });
  }
}

class GetJumlahAmalan extends StatelessWidget {
  final String documentId;
  final String uid;
  const GetJumlahAmalan({Key? key, required this.documentId, required this.uid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference amalan =
        FirebaseFirestore.instance.collection('sunnahList');

    return FutureBuilder<DocumentSnapshot>(
        future: amalan.doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            if (data['amalanId'] == uid) {
              return Text('Target: ${data['jumlah']} ${data['unit']} ');
            } else {
              return const Text('Access denied');
            }
          }
          return const Text('Loading');
        });
  }
}
