import 'ads_abstract_class.dart';

class AdsConfig {
  const AdsConfig({
    required this.mediation,
    this.appOpen,
    this.interstitial,
    this.rewarded,
    this.banner,
    this.native,
    this.appOpenAdmobFallback = const <String>[],
    this.appOpenAdmobAlwaysFallback = false,
  });

  factory AdsConfig.fromJson(Map<String, dynamic> json) {
    return AdsConfig(
      mediation: json['mediation'] as String? ?? '',
      appOpen: json['appOpen'] as String? ?? '',
      interstitial: json['interstitial'] as String? ?? '',
      rewarded: json['rewarded'] as String? ?? '',
      banner: json['banner'] as String? ?? '',
      native: json['native'] as String? ?? '',
      appOpenAdmobFallback: List<String>.from(
          json['appOpenAdmobFallback'] as List<dynamic>? ?? []),
      appOpenAdmobAlwaysFallback:
          json['appOpenAdmobAlwaysFallback'] as bool? ?? false,
    );
  }

  final String mediation;
  final String? appOpen;
  final String? interstitial;
  final String? rewarded;
  final String? banner;
  final String? native;
  final List<String> appOpenAdmobFallback;
  final bool appOpenAdmobAlwaysFallback;

  Map<String, dynamic> toJson() {
    return {
      'mediation': mediation,
      'interstitial': interstitial,
      'rewarded': rewarded,
      'appOpen': appOpen,
      'banner': banner,
      'native': native,
      'appOpenAdmobFallback': appOpenAdmobFallback,
      'appOpenAdmobAlwaysFallback': appOpenAdmobAlwaysFallback,
    };
  }
}

///AppOpen广告回调
class AppOpenThAdCallback extends ThAdsFullScreenCallBack {
  const AppOpenThAdCallback({
    super.onThAdLoadCallback,
    super.onThAdLoadFailedCallback,
    super.onThAdClickedCallback,
    super.onThAdRevenuePaidCallback,
    super.onThAdDisplayedCallback,
    super.onThAdDisplayFailedCallback,
    super.onThAdHiddenCallback,
  });
}

///Interstitial广告回调
class InterstitialThAdCallback extends ThAdsFullScreenCallBack {
  const InterstitialThAdCallback({
    super.onThAdLoadCallback,
    super.onThAdLoadFailedCallback,
    super.onThAdClickedCallback,
    super.onThAdRevenuePaidCallback,
    super.onThAdDisplayedCallback,
    super.onThAdDisplayFailedCallback,
    super.onThAdHiddenCallback,
  });
}

///Reward广告回调
class RewardThAdCallback extends ThAdsFullScreenCallBack {
  const RewardThAdCallback({
    super.onThAdLoadCallback,
    super.onThAdLoadFailedCallback,
    super.onThAdClickedCallback,
    super.onThAdRevenuePaidCallback,
    super.onThAdDisplayedCallback,
    super.onThAdDisplayFailedCallback,
    super.onThAdHiddenCallback,
    this.onThAdReceivedRewardCallback,
  });

  final void Function()? onThAdReceivedRewardCallback;
}

///Banner广告回调
class BannerThAdCallback extends ThAdsCallBack {
  const BannerThAdCallback({
    super.onThAdLoadCallback,
    super.onThAdLoadFailedCallback,
    super.onThAdClickedCallback,
    super.onThAdRevenuePaidCallback,
    this.onThAdExpandedCallback,
    this.onThAdCollapsedCallback,
  });

  final void Function()? onThAdExpandedCallback;
  final void Function()? onThAdCollapsedCallback;
}

///Native广告回调
class NativeThAdCallback extends ThAdsCallBack {
  const NativeThAdCallback({
    super.onThAdLoadCallback,
    super.onThAdLoadFailedCallback,
    super.onThAdClickedCallback,
    super.onThAdRevenuePaidCallback,
  });
}

///前台后台回调
class ForeBackThCallback {
  const ForeBackThCallback({
    this.foreStayCallback,
    this.backStayCallback,
  });

  final void Function()? foreStayCallback;
  final void Function()? backStayCallback;
}
