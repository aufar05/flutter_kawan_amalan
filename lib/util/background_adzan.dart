import 'package:flutter/material.dart';

class BackgroundChanger {
  static AssetImage getBackgroundAsset() {
    var now = DateTime.now();
    if (now.hour >= 4 && now.hour < 6) {
      return const AssetImage("lib/images/subuhKecil.png");
    } else if (now.hour >= 6 && now.hour < 10) {
      return const AssetImage("lib/images/terbit.png");
    } else if (now.hour >= 10 && now.hour < 15) {
      return const AssetImage("lib/images/siang.png");
    } else if (now.hour >= 15 && now.hour < 18) {
      return const AssetImage("lib/images/sore.png");
    } else if (now.hour >= 18 && now.hour < 19) {
      return const AssetImage("lib/images/maghribfix.png");
    } else {
      return const AssetImage("lib/images/isya.png");
    }
  }
}
