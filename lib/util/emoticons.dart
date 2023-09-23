import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmoticonSelector extends StatefulWidget {
  const EmoticonSelector({Key? key}) : super(key: key);

  @override
  _EmoticonSelectorState createState() => _EmoticonSelectorState();
}

class _EmoticonSelectorState extends State<EmoticonSelector> {
  String selectedEmoticon = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (selectedEmoticon != '😐' && selectedEmoticon != '🙁')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEmoticon = '😊';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: selectedEmoticon == '😊'
                        ? Lottie.asset(
                            'lib/icons/emojiHappy.json',
                            width: 50,
                            height: 50,
                          )
                        : const Text(
                            '😊',
                            style: TextStyle(fontSize: 25),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        if (selectedEmoticon != '😊' && selectedEmoticon != '🙁')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEmoticon = '😐';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: selectedEmoticon == '😐'
                        ? Lottie.asset(
                            'lib/icons/emojiNetral.json',
                            width: 50,
                            height: 50,
                          )
                        : const Text(
                            '😐',
                            style: TextStyle(fontSize: 25),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        if (selectedEmoticon != '😊' && selectedEmoticon != '😐')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEmoticon = '🙁';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: selectedEmoticon == '🙁'
                        ? Lottie.asset(
                            'lib/icons/emojiSad.json',
                            width: 50,
                            height: 50,
                          )
                        : const Text(
                            '🙁',
                            style: TextStyle(fontSize: 25),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
      ],
    );
  }
}
