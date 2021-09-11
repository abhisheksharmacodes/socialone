import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7438888956361165/9457268870';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7438888956361165/3367337397';
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2247696110';
    }
    throw new UnsupportedError("Unsupported platform");
  }
}
