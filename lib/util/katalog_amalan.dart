import 'package:flutter/material.dart';

class KatalogAmalan extends StatelessWidget {
  final image;
  final String judul;

  const KatalogAmalan({
    Key? key,
    required this.image,
    required this.judul,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.015),
      child: Container(
          padding: EdgeInsets.all(size.height * 0.015),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                    padding: EdgeInsets.all(size.height * 0.015),
                    color: const Color.fromARGB(255, 34, 96, 102),
                    child: image),
              ),
              const SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //judul
                  Text(
                    judul,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.025),
                  ),
                  //subjudul
                  Text(
                    'Tekan untuk melihat dalil',
                    style: TextStyle(fontSize: size.height * 0.02),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
