import 'dart:async';

import 'package:flutter_th_common_ads/flutter_th_common_ads.dart';
import 'package:flutter_th_common_ads/src/ads_config_store.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsAdmobAppOpen extends AdsCommon {
  late String _adUnitId = '';
  Completer<AdState> _adCompleter = Completer<AdState>();
  String _adSceneStore = '';
  AppOpenAd? _appOpenAd;

  AppOpenThAdCallback? _appOpenThAdCallback() {
    return AdsConfigStore().appOpenThAdCallback;
  }

  @override
  bool preCheck() {
    return _adUnitId.isNotEmpty;
  }

  @override
  void init() {
    _adUnitId = AdsConfigStore().adsConfig.appOpen ?? '';
  }

  @override
  void load() {
    if (!AdsConfigStore().shouldLoadAds) {
      return;
    }
    if (!preCheck()) {
      return;
    }
    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          // Keep a reference to the ad so you can show it later.
          _appOpenAd = ad;
          _appOpenThAdCallback()?.onThAdLoadCallback?.call(
                AdLoadedInfo(
                  adUnitId: ad.adUnitId,
                ),
              );
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {},
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {
              _appOpenThAdCallback()?.onThAdDisplayedCallback?.call();
            },
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              // Dispose the ad here to free resources.
              if (!_adCompleter.isCompleted) {
                _adCompleter.complete(AdState.showFail);
              }
              ad.dispose();
              load();
              _appOpenThAdCallback()?.onThAdDisplayFailedCallback?.call();
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              if (!_adCompleter.isCompleted) {
                _adCompleter.complete(AdState.closed);
              }
              ad.dispose();
              load();
              _appOpenThAdCallback()?.onThAdHiddenCallback?.call();
            },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {
              _appOpenThAdCallback()?.onThAdClickedCallback?.call();
            },
          );
          ad.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision,
              String currencyCode) {
            _appOpenThAdCallback()?.onThAdRevenuePaidCallback?.call(
                  AdsPaidInfo(
                    mediation: 'admob',
                    revenueFrom: 'admob_pingback',
                    networkName: getNetworkName(ad.responseInfo),
                    adUnitId: ad.adUnitId,
                    adType: AdType.appOpen,
                    currency: currencyCode,
                    revenue: valueMicros * 1.0 / 1000000,
                    revenuePrecision: precision.name,
                    scene: _adSceneStore,
                    thirdPartyAdPlacementId: null,
                  ),
                );
          };
        },
        onAdFailedToLoad: (LoadAdError error) {
          Future.delayed(const Duration(seconds: 5), () => load());
          _appOpenThAdCallback()?.onThAdLoadFailedCallback?.call(
                AdErrorInfo(
                  adUnitId: _adUnitId,
                  errorCode: error.code,
                  errorMessage: error.message,
                  mediationType: MediationType.admob,
                ),
              );
        },
      ),
    );
  }

  @override
  Future<bool> ready() async {
    return _appOpenAd != null;
  }

  @override
  Future<AdState> show(String scene) async {
    _adSceneStore = scene;
    if (!await ready()) {
      load();
      return AdState.notReady;
    }
    _adCompleter = Completer<AdState>();
    _appOpenAd!.show();
    return _adCompleter.future;
  }
}
