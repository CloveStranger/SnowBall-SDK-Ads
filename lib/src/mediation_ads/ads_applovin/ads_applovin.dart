import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_th_common_ads/flutter_th_common_ads.dart';
import 'package:flutter_th_common_ads/src/ads_config_store.dart';
import 'package:flutter_th_common_ads/src/mediation_ads/ads_applovin/app_open/applovin_app_open.dart';
import 'package:flutter_th_common_ads/src/mediation_ads/ads_applovin/banner/applovin_banner.dart';
import 'package:flutter_th_common_ads/src/mediation_ads/ads_applovin/interstitial/applovin_interstitial.dart';
import 'package:flutter_th_common_ads/src/mediation_ads/ads_applovin/reward/applovin_reward.dart';

class AdsApplovin extends AdsUtilsCommon {
  static AdsApplovin? _instance;

  AdsApplovin._();

  AdsApplovin get instance => AdsApplovin._instanceMake();

  factory AdsApplovin() {
    return AdsApplovin._instanceMake();
  }

  factory AdsApplovin._instanceMake() {
    _instance ??= AdsApplovin._();
    return _instance!;
  }

  final ApplovinAppOpen applovinAppOpen = ApplovinAppOpen();
  final ApplovinInterstitial applovinInterstitial = ApplovinInterstitial();
  final ApplovinReward applovinReward = ApplovinReward();
  final ApplovinBanner applovinBanner = ApplovinBanner();

  bool _hasInit = false;

  @override
  Future<void> init(AdsConfig adsConfig, [String? sdkKey]) async {
    AdsConfigStore().adsConfig = adsConfig;

    if (sdkKey == null) {
      throw 'Max sdk key is must';
    }

    final isAdMobAppOpen =
        AdsConfigStore().adsConfig.appOpenAdmobAlwaysFallback;

    if (isAdMobAppOpen) {
      applovinAppOpen.init();
    }

    await AppLovinMAX.initialize(sdkKey);
    AppLovinMAX.setHasUserConsent(true);
    AppLovinMAX.setDoNotSell(false);
    if (kDebugMode) {
      AppLovinMAX.setVerboseLogging(true);
    }

    _hasInit = true;

    if (!isAdMobAppOpen) {
      applovinAppOpen.init();
    }
    applovinInterstitial.init();
    applovinReward.init();
  }

  @override
  void activeAds() {
    if (!_hasInit) {
      return;
    }
    applovinAppOpen.load();
    applovinInterstitial.load();
    applovinReward.load();
  }

  @override
  Future<bool> checkAdsReady(AdType adType) async {
    if (adType == AdType.appOpen) {
      return await applovinAppOpen.ready();
    } else if (adType == AdType.interstitial) {
      return await applovinInterstitial.ready();
    } else if (adType == AdType.rewarded) {
      return await applovinReward.ready();
    }
    return false;
  }

  @override
  void showAdsDebugPage() {
    AppLovinMAX.showMediationDebugger();
  }

  @override
  Future<AdState> showAppOpenAds({String scene = 'test'}) async {
    return await applovinAppOpen.show(scene);
  }

  @override
  Future<AdState> showInterstitialAds({String scene = 'test'}) async {
    return await applovinInterstitial.show(scene);
  }

  @override
  Future<AdState> showRewardedAd({String scene = 'test'}) async {
    return await applovinReward.show(scene);
  }

  @override
  Future<void> showBannerAd({String scene = 'test'}) async {
    applovinBanner.show(scene);
  }
}
