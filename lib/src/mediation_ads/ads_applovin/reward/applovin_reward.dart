import 'dart:async';

import 'package:applovin_max/applovin_max.dart';

import '../../../ads_abstract_class.dart';
import '../../../ads_class.dart';
import '../../../ads_config_store.dart';
import '../../../ads_enums.dart';
import '../../../ads_model.dart';

class ApplovinReward extends AdsCommon {
  late String _adUnitId = '';
  Completer<AdState> _adCompleter = Completer<AdState>();
  String _adSceneStore = '';

  RewardThAdCallback? _rewardThAdCallback() {
    return AdsConfigStore().rewardThAdCallback;
  }

  @override
  bool preCheck() {
    return _adUnitId.isNotEmpty;
  }

  @override
  void init() {
    _adUnitId = AdsConfigStore().adsConfig.rewarded ?? '';
    _setListener();
  }

  @override
  Future<bool> ready() async {
    if (!preCheck()) {
      return false;
    }
    bool isReady = await AppLovinMAX.isRewardedAdReady(_adUnitId) ?? false;
    return isReady;
  }

  @override
  void load() async {
    if (!AdsConfigStore().shouldLoadAds) {
      return;
    }
    if (!preCheck()) {
      return;
    }
    try {
      if (!await ready()) {
        AppLovinMAX.loadRewardedAd(_adUnitId);
      }
    } catch (e) {
      adsCommonDebugPrint(e);
    }
  }

  @override
  Future<AdState> show(String scene) async {
    _adSceneStore = scene;
    if (!await ready()) {
      load();
      return AdState.notReady;
    }
    if (!preCheck()) {
      return AdState.notReady;
    }
    _adCompleter = Completer<AdState>();
    AppLovinMAX.showRewardedAd(_adUnitId);
    return _adCompleter.future;
  }

  void _setListener() {
    AppLovinMAX.setRewardedAdListener(
      RewardedAdListener(
        onAdLoadedCallback: (MaxAd ad) {
          _rewardThAdCallback()?.onThAdLoadCallback?.call(
                AdLoadedInfo(
                  adUnitId: ad.adUnitId,
                ),
              );
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          Future.delayed(const Duration(seconds: 5), () => load());
          _rewardThAdCallback()?.onThAdLoadFailedCallback?.call(
                AdErrorInfo(
                  adUnitId: adUnitId,
                  errorCode: error.code.value,
                  errorMessage: error.message,
                  mediationType: MediationType.max,
                ),
              );
        },
        onAdDisplayedCallback: (ad) {
          _rewardThAdCallback()?.onThAdDisplayedCallback?.call();
        },
        onAdDisplayFailedCallback: (ad, error) {
          if (!_adCompleter.isCompleted) {
            _adCompleter.complete(AdState.showFail);
          }
          load();
          _rewardThAdCallback()?.onThAdDisplayFailedCallback?.call();
        },
        onAdClickedCallback: (ad) {
          _rewardThAdCallback()?.onThAdClickedCallback?.call();
        },
        onAdHiddenCallback: (ad) {
          if (!_adCompleter.isCompleted) {
            _adCompleter.complete(AdState.closed);
          }
          load();
          _rewardThAdCallback()?.onThAdHiddenCallback?.call();
        },
        onAdRevenuePaidCallback: (ad) {
          _rewardThAdCallback()?.onThAdRevenuePaidCallback?.call(
                AdsPaidInfo(
                  mediation: 'max',
                  revenueFrom: 'applovin_max_ilrd',
                  networkName: ad.networkName,
                  adUnitId: ad.adUnitId,
                  adType: AdType.rewarded,
                  currency: 'USD',
                  revenue: ad.revenue,
                  revenuePrecision: ad.revenuePrecision,
                  scene: _adSceneStore,
                ),
              );
        },
        onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {
          if (!_adCompleter.isCompleted) {
            _adCompleter.complete(AdState.rewarded);
          }
          _rewardThAdCallback()?.onThAdReceivedRewardCallback?.call();
        },
      ),
    );
  }
}
