import 'dart:io';

import '../snowball_sdk_ads.dart';
import 'ads_class.dart';

class AdsConstants {
  static Map<String, String> adsAdapterMap = {
    'admob.AdMobAdapter': 'admob_native',
    'facebook': 'facebook',
    'applovin': 'applovin_sdk',
    'adcolony': 'adcolony',
    'fyber': 'fyber',
    'ironsource': 'ironsource',
    'inmobi': 'inmobi',
    'tapjoy': 'tapjoy',
    'unity': 'unity',
    'vungle': 'vungle',
    'pangle': 'pangle',
    'smaato': 'smaato',
    'thgoogleadmanager': 'google_ad_manager',
  };

  static AdsConfig debugAdsConfig = () {
    final bool isIos = Platform.isIOS;
    return AdsConfig(
      mediation: MediationType.admob.name,
      appOpen: isIos
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-3940256099942544/9257395921',
      interstitial: isIos
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712',
      rewarded: isIos
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917',
      banner: isIos
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-3940256099942544/6300978111',
      native: isIos
          ? 'ca-app-pub-3940256099942544/3986624511'
          : 'ca-app-pub-3940256099942544/2247696110',
      appOpenAdmobFallback: [],
    );
  }();

  static Map<String, int> adsBaseShowInterval = {
    'appOpen': 30,
    'interstitial': 15,
    'rewarded': 5,
  };
}
