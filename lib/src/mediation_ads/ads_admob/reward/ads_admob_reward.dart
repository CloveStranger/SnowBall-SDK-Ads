import 'dart:async';

import 'package:flutter_th_common_ads/flutter_th_common_ads.dart';
import 'package:flutter_th_common_ads/src/ads_config_store.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsAdmobReward extends AdsCommon {
  late String _adUnitId = '';
  Completer<AdState> _adCompleter = Completer<AdState>();
  String _adSceneStore = '';
  RewardedAd? _rewardedAd;

  RewardThAdCallback? _rewardThAdCallback() {
    return AdsConfigStore().rewardThAdCallback;
  }

  @override
  bool preCheck() {
    // TODO: implement preCheck
    return _adUnitId.isNotEmpty;
  }

  @override
  void init() {
    _adUnitId = AdsConfigStore().adsConfig.rewarded ?? '';
  }

  @override
  void load() {
    if (!AdsConfigStore().shouldLoadAds) {
      return;
    }
    if (!preCheck()) {
      return;
    }
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          // Keep a reference to the ad so you can show it later.
          _rewardedAd = ad;
          _rewardThAdCallback()?.onThAdLoadCallback?.call(
                AdLoadedInfo(
                  adUnitId: ad.adUnitId,
                ),
              );
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {},
            // Called when an impression occurs on the ad.
            onAdImpression: (ad) {
              _rewardThAdCallback()?.onThAdDisplayedCallback?.call();
            },
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              // Dispose the ad here to free resources.
              if (!_adCompleter.isCompleted) {
                _adCompleter.complete(AdState.showFail);
              }
              ad.dispose();
              load();
              _rewardThAdCallback()?.onThAdDisplayFailedCallback?.call();
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              if (!_adCompleter.isCompleted) {
                _adCompleter.complete(AdState.closed);
              }
              ad.dispose();
              load();
              _rewardThAdCallback()?.onThAdHiddenCallback?.call();
            },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {
              _rewardThAdCallback()?.onThAdClickedCallback?.call();
            },
          );
          ad.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
            _rewardThAdCallback()?.onThAdRevenuePaidCallback?.call(
                  AdsPaidInfo(
                    mediation: 'admob',
                    revenueFrom: 'admob_pingback',
                    networkName: getNetworkName(ad.responseInfo),
                    adUnitId: ad.adUnitId,
                    adType: AdType.rewarded,
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
          _rewardThAdCallback()?.onThAdLoadFailedCallback?.call(
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
    return _rewardedAd != null;
  }

  @override
  Future<AdState> show(String scene) async {
    _adSceneStore = scene;
    if (!await ready()) {
      load();
      return AdState.notReady;
    }
    _adCompleter = Completer<AdState>();
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        // Reward the user for watching an ad.
        if (!_adCompleter.isCompleted) {
          _adCompleter.complete(AdState.rewarded);
        }
      },
    );
    return _adCompleter.future;
  }
}
