import 'ads_class.dart';

class AdsConfigStore {
  factory AdsConfigStore() {
    return AdsConfigStore._makeInstance();
  }

  AdsConfigStore._();

  factory AdsConfigStore._makeInstance() {
    _instance ??= AdsConfigStore._();
    return _instance!;
  }

  static AdsConfigStore? _instance;

  AdsConfigStore get instance => AdsConfigStore._makeInstance();

  late AdsConfig adsConfig;

  AppOpenThAdCallback? appOpenThAdCallback;

  InterstitialThAdCallback? interstitialThAdCallback;

  RewardThAdCallback? rewardThAdCallback;

  BannerThAdCallback? bannerThAdCallback;

  NativeThAdCallback? nativeThAdCallback;

  bool shouldLoadAds = true;
}
