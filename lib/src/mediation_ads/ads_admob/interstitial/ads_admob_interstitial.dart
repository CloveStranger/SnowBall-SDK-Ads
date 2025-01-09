import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../ads_abstract_class.dart';
import '../../../ads_class.dart';
import '../../../ads_config_store.dart';
import '../../../ads_enums.dart';
import '../../../ads_model.dart';

class AdsAdmobInterstitial extends AdsCommon {
  late String _adUnitId = '';
  Completer<AdState> _adCompleter = Completer<AdState>();
  String _adSceneStore = '';
  InterstitialAd? _interstitialAd;

  InterstitialThAdCallback? _interstitialThAdCallback() {
    return AdsConfigStore().interstitialThAdCallback;
  }

  @override
  bool preCheck() {
    // TODO: implement preCheck
    return _adUnitId.isNotEmpty;
  }

  @override
  void init() {
    // TODO: implement init
    _adUnitId = AdsConfigStore().adsConfig.interstitial ?? '';
  }

  @override
  void load() {
    if (!AdsConfigStore().shouldLoadAds) {
      return;
    }
    if (!preCheck()) {
      return;
    }
    // TODO: implement load
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // Keep a reference to the ad so you can show it later.
          _interstitialAd = ad;
          _interstitialThAdCallback()?.onThAdLoadCallback?.call(
                AdLoadedInfo(
                  adUnitId: ad.adUnitId,
                ),
              );
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {},
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {
              _interstitialThAdCallback()?.onThAdDisplayedCallback?.call();
            },
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              // Dispose the ad here to free resources.
              if (!_adCompleter.isCompleted) {
                _adCompleter.complete(AdState.showFail);
              }
              ad.dispose();
              load();
              _interstitialThAdCallback()?.onThAdDisplayFailedCallback?.call();
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              if (!_adCompleter.isCompleted) {
                _adCompleter.complete(AdState.closed);
              }
              ad.dispose();
              load();
              _interstitialThAdCallback()?.onThAdHiddenCallback?.call();
            },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {
              _interstitialThAdCallback()?.onThAdClickedCallback?.call();
            },
          );
          ad.onPaidEvent = (Ad ad, double valueMicros, PrecisionType precision,
              String currencyCode) {
            _interstitialThAdCallback()?.onThAdRevenuePaidCallback?.call(
                  AdsPaidInfo(
                    mediation: 'admob',
                    revenueFrom: 'admob_pingback',
                    networkName: getNetworkName(ad.responseInfo),
                    adUnitId: ad.adUnitId,
                    adType: AdType.interstitial,
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
          _interstitialThAdCallback()?.onThAdLoadFailedCallback?.call(
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
    // TODO: implement ready
    return _interstitialAd != null;
  }

  @override
  Future<AdState> show(String scene) async {
    // TODO: implement show
    _adSceneStore = scene;
    if (!await ready()) {
      load();
      return AdState.notReady;
    }
    _adCompleter = Completer<AdState>();
    _interstitialAd!.show();
    return _adCompleter.future;
  }
}
