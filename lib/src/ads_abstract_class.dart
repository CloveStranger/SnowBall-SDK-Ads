import 'package:flutter/foundation.dart';

import '../snowball_sdk_ads.dart';
import 'ads_class.dart';

///各类型广告基本接口
abstract class AdsCommon {
  void init();

  bool preCheck();

  void load();

  Future<bool> ready();

  Future<AdState> show(String scene);

  void adsCommonDebugPrint(dynamic info) {
    debugPrint('==> Ads Common Print ${info.toString()}');
  }
}

///广告平台接口
abstract class AdsUtilsCommon {
  Future<void> init(AdsConfig adsConfig, [String? sdkKey]);

  void activeAds();

  Future<bool> checkAdsReady(AdType adType);

  Future<AdState> showAppOpenAds({String scene = 'test'});

  Future<AdState> showInterstitialAds({String scene = 'test'});

  Future<AdState> showRewardedAd({String scene = 'test'});

  Future<void> showBannerAd({String scene = 'test'});

  void showAdsDebugPage();

  void adsUtilsCommonDebugPrint(dynamic info) {}
}

///基本广告回调
abstract class ThAdsCallBack {
  const ThAdsCallBack({
    this.onThAdLoadCallback,
    this.onThAdLoadFailedCallback,
    this.onThAdClickedCallback,
    this.onThAdRevenuePaidCallback,
  });

  final void Function(AdLoadedInfo adLoadedInfo)? onThAdLoadCallback;
  final void Function(AdErrorInfo adErrorInfo)? onThAdLoadFailedCallback;
  final void Function()? onThAdClickedCallback;
  final void Function(AdsPaidInfo adsPaidInfo)? onThAdRevenuePaidCallback;
}

///全屏类型广告回调
abstract class ThAdsFullScreenCallBack extends ThAdsCallBack {
  const ThAdsFullScreenCallBack({
    super.onThAdLoadCallback,
    super.onThAdLoadFailedCallback,
    super.onThAdClickedCallback,
    super.onThAdRevenuePaidCallback,
    this.onThAdDisplayedCallback,
    this.onThAdDisplayFailedCallback,
    this.onThAdHiddenCallback,
  });

  final void Function()? onThAdDisplayedCallback;
  final void Function()? onThAdDisplayFailedCallback;
  final void Function()? onThAdHiddenCallback;
}
