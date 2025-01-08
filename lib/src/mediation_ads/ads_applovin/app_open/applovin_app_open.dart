import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter_th_common_ads/flutter_th_common_ads.dart';
import 'package:flutter_th_common_ads/src/ads_config_store.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ApplovinAppOpen extends AdsCommon {
  Completer<AdState> _adCompleter = Completer<AdState>();

  String _adSceneStore = '';

  AppOpenThAdCallback? _appOpenThAdCallback() {
    return AdsConfigStore().appOpenThAdCallback;
  }

  ///Applovin Config
  late String _adUnitId = '';

  ///Admob Config
  final bool _appOpenAdmobAlwaysFallback =
      AdsConfigStore().adsConfig.appOpenAdmobAlwaysFallback;

  bool _appOpenIsShowing = false;
  List<String> _appOpenAdmobFallback = [];

  AppOpenAd? _appOpenAd;

  @override
  void init() {
    if (_appOpenAdmobAlwaysFallback) {
      admobFallbackConfig();
    } else {
      _adUnitId = AdsConfigStore().adsConfig.appOpen ?? '';
      _setListener();
    }
  }

  @override
  bool preCheck() {
    return _adUnitId.isNotEmpty;
  }

  Future<void> admobFallbackConfig() async {
    if (!_appOpenAdmobAlwaysFallback) {
      return;
    }
    _appOpenAdmobFallback = AdsConfigStore().adsConfig.appOpenAdmobFallback;
    await MobileAds.instance.initialize();
    adsCommonDebugPrint('Admob Instance Initialized');
    load();
  }

  void _admobLoad(int curLoadIndex) {
    if (_appOpenAdmobFallback.isEmpty) {
      return;
    }
    AppOpenAd.load(
      adUnitId: _appOpenAdmobFallback[curLoadIndex],
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          ad.onPaidEvent = (
            Ad ad,
            double valueMicros,
            PrecisionType precision,
            String currencyCode,
          ) {
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
          _appOpenThAdCallback()?.onThAdLoadCallback?.call(
                AdLoadedInfo(adUnitId: ad.adUnitId),
              );
          adsCommonDebugPrint('app open load');
        },
        onAdFailedToLoad: (LoadAdError ad) {
          Future.delayed(
            const Duration(seconds: 5),
            () => _admobLoad(
              (curLoadIndex + 1) % _appOpenAdmobFallback.length,
            ),
          );
          _appOpenThAdCallback()?.onThAdLoadFailedCallback?.call(
                AdErrorInfo(
                  adUnitId: _appOpenAdmobFallback[curLoadIndex],
                  errorCode: ad.code,
                  errorMessage: ad.message,
                  mediationType: MediationType.admob,
                ),
              );
          adsCommonDebugPrint('app open load failed');
        },
      ),
    );
  }

  Future<AdState> _admobShow() async {
    if (_appOpenIsShowing) {
      return AdState.shouldNotShow;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        adsCommonDebugPrint('app open displayed');
        _appOpenIsShowing = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        adsCommonDebugPrint('app open displayed failed');
        _appOpenIsShowing = false;
        ad.dispose();
        _appOpenAd = null;
        _admobLoad(0);
        if (!_adCompleter.isCompleted) {
          _adCompleter.complete(AdState.showFail);
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        adsCommonDebugPrint('app open hidden');
        _appOpenIsShowing = false;
        ad.dispose();
        _appOpenAd = null;
        _admobLoad(0);
        if (!_adCompleter.isCompleted) {
          _adCompleter.complete(AdState.closed);
        }
      },
      onAdClicked: (ad) {
        adsCommonDebugPrint('app open was clicked');
      },
    );
    _adCompleter = Completer<AdState>();
    _appOpenAd!.show();
    return _adCompleter.future;
  }

  @override
  Future<bool> ready() async {
    if (_appOpenAdmobAlwaysFallback) {
      return _appOpenAd != null;
    }
    if (!preCheck()) {
      return false;
    }
    return await AppLovinMAX.isAppOpenAdReady(_adUnitId) ?? false;
  }

  @override
  void load() async {
    if (!AdsConfigStore().shouldLoadAds) {
      return;
    }
    if (_appOpenAdmobAlwaysFallback) {
      if (!await ready()) {
        _admobLoad(0);
      }
      return;
    }
    if (!preCheck()) {
      return;
    }
    try {
      if (!await ready()) {
        _setListener();
        AppLovinMAX.loadAppOpenAd(_adUnitId);
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
    if (_appOpenAdmobAlwaysFallback) {
      return _admobShow();
    }
    if (!preCheck()) {
      return AdState.notReady;
    }
    _adCompleter = Completer<AdState>();
    AppLovinMAX.showAppOpenAd(_adUnitId);
    return _adCompleter.future;
  }

  void _setListener() {
    if (_appOpenAdmobAlwaysFallback) {
      return;
    }
    AppLovinMAX.setAppOpenAdListener(
      AppOpenAdListener(
        onAdLoadedCallback: (MaxAd ad) {
          adsCommonDebugPrint('app open load');
          _appOpenThAdCallback()?.onThAdLoadCallback?.call(
                AdLoadedInfo(
                  adUnitId: ad.adUnitId,
                ),
              );
        },
        onAdLoadFailedCallback: (adUnitId, MaxError error) {
          adsCommonDebugPrint('app open load failed');
          Future.delayed(const Duration(seconds: 5), () => load());
          _appOpenThAdCallback()?.onThAdLoadFailedCallback?.call(
                AdErrorInfo(
                  adUnitId: adUnitId,
                  errorCode: error.code.value,
                  errorMessage: error.message,
                  mediationType: MediationType.max,
                ),
              );
        },
        onAdDisplayedCallback: (ad) {
          adsCommonDebugPrint('app open displayed');
          _appOpenThAdCallback()?.onThAdDisplayedCallback?.call();
        },
        onAdDisplayFailedCallback: (ad, error) {
          adsCommonDebugPrint('app open displayed failed');
          if (!_adCompleter.isCompleted) {
            _adCompleter.complete(AdState.showFail);
          }
          load();
          _appOpenThAdCallback()?.onThAdDisplayFailedCallback?.call();
        },
        onAdClickedCallback: (ad) {
          adsCommonDebugPrint('app open was clicked');
          _appOpenThAdCallback()?.onThAdClickedCallback?.call();
        },
        onAdHiddenCallback: (ad) {
          adsCommonDebugPrint('app open hidden');
          if (!_adCompleter.isCompleted) {
            _adCompleter.complete(AdState.closed);
          }
          load();
          _appOpenThAdCallback()?.onThAdHiddenCallback?.call();
        },
        onAdRevenuePaidCallback: (MaxAd ad) {
          adsCommonDebugPrint('app open revenue paid');
          _appOpenThAdCallback()?.onThAdRevenuePaidCallback?.call(
                AdsPaidInfo(
                  mediation: 'max',
                  revenueFrom: 'applovin_max_ilrd',
                  networkName: ad.networkName,
                  adUnitId: ad.adUnitId,
                  adType: AdType.appOpen,
                  currency: 'USD',
                  revenue: ad.revenue,
                  revenuePrecision: ad.revenuePrecision,
                  scene: _adSceneStore,
                ),
              );
        },
      ),
    );
  }
}
