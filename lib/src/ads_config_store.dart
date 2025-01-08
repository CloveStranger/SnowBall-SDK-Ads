import 'package:flutter_th_common_ads/flutter_th_common_ads.dart';

class AdsConfigStore {
  static AdsConfigStore? _instance;

  AdsConfigStore._();

  factory AdsConfigStore._makeInstance() {
    _instance ??= AdsConfigStore._();
    return _instance!;
  }

  factory AdsConfigStore() {
    return AdsConfigStore._makeInstance();
  }

  AdsConfigStore get instance => AdsConfigStore._makeInstance();

  late AdsConfig adsConfig;

  AppOpenThAdCallback? appOpenThAdCallback;

  InterstitialThAdCallback? interstitialThAdCallback;

  RewardThAdCallback? rewardThAdCallback;

  BannerThAdCallback? bannerThAdCallback;

  NativeThAdCallback? nativeThAdCallback;

  bool shouldLoadAds = true;
}
