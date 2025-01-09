import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads_abstract_class.dart';
import '../../ads_class.dart';
import '../../ads_config_store.dart';
import '../../ads_enums.dart';
import 'app_open/ads_admob_app_open.dart';
import 'interstitial/ads_admob_interstitial.dart';
import 'reward/ads_admob_reward.dart';

class AdsAdmob extends AdsUtilsCommon {
  static AdsAdmob? _instance;

  AdsAdmob._();

  AdsAdmob get instance => AdsAdmob._makeInstance();

  factory AdsAdmob() {
    return AdsAdmob._makeInstance();
  }

  factory AdsAdmob._makeInstance() {
    _instance ??= AdsAdmob._();
    return _instance!;
  }

  final AdsAdmobAppOpen adsAdmobAppOpen = AdsAdmobAppOpen();
  final AdsAdmobInterstitial adsAdmobInterstitial = AdsAdmobInterstitial();
  final AdsAdmobReward adsAdmobReward = AdsAdmobReward();

  bool _hasInit = false;

  @override
  Future<void> init(AdsConfig adsConfig, [String? sdkKey]) async {
    // TODO: implement init
    AdsConfigStore().adsConfig = adsConfig;
    await MobileAds.instance.initialize();
    _hasInit = true;
    adsAdmobAppOpen.init();
    adsAdmobInterstitial.init();
    adsAdmobReward.init();
  }

  @override
  void activeAds() {
    if (!_hasInit) {
      return;
    }
    adsAdmobAppOpen.load();
    adsAdmobInterstitial.load();
    adsAdmobReward.load();
  }

  @override
  Future<bool> checkAdsReady(AdType adType) async {
    // TODO: implement checkAdsReady
    if (adType == AdType.appOpen) {
      return await adsAdmobAppOpen.ready();
    } else if (adType == AdType.interstitial) {
      return await adsAdmobInterstitial.ready();
    } else if (adType == AdType.rewarded) {
      return await adsAdmobReward.ready();
    }
    return false;
  }

  @override
  void showAdsDebugPage() {
    // TODO: implement showAdsDebugPage
    MobileAds.instance.openAdInspector((var error) {
      // Error will be non-null if ad inspector closed due to an error.
    });
  }

  @override
  Future<AdState> showAppOpenAds({String scene = 'test'}) async {
    // TODO: implement showAppOpenAds
    return await adsAdmobAppOpen.show(scene);
  }

  @override
  Future<AdState> showInterstitialAds({String scene = 'test'}) async {
    // TODO: implement showInterstitialAds
    return await adsAdmobInterstitial.show(scene);
  }

  @override
  Future<AdState> showRewardedAd({String scene = 'test'}) async {
    // TODO: implement showRewardedAd
    return await adsAdmobReward.show(scene);
  }

  @override
  Future<void> showBannerAd({String scene = 'test'}) async {}
}
