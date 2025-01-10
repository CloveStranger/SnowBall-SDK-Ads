import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_abstract_class.dart';
import 'ads_class.dart';
import 'ads_config_store.dart';
import 'ads_enums.dart';
import 'ads_remote_config.dart';
import 'ads_scene.dart';
import 'ads_type_def.dart';
import 'mediation_ads/ads_admob/ads_admob.dart';
import 'mediation_ads/ads_applovin/ads_applovin.dart';
import 'ump/use_ump.dart';

class AdsLib extends ChangeNotifier {
  factory AdsLib() {
    return AdsLib._makeInstance();
  }

  AdsLib._();

  factory AdsLib._makeInstance() {
    _instance ??= AdsLib._();
    return _instance!;
  }

  static AdsLib? _instance;

  AdsLib get instance => AdsLib._makeInstance();

  final AdsRemoteConfig _adsRemoteConfig = AdsRemoteConfig();

  List<AdType> get _disableAdType => _adsRemoteConfig.disableAdType;

  List<String> get _disableAdsScenes => _adsRemoteConfig.disableAdsScenes;

  Map<AdType, int> get _adsShowInterval => _adsRemoteConfig.adsShowInterval;

  Map<String, int> get _adsShowIntervalByScene =>
      _adsRemoteConfig.adsShowIntervalByScene;

  bool get shouldWidgetAdsShow => _adsRemoteConfig.shouldWidgetAdsShow.value;

  bool get showCloseIcon => _adsRemoteConfig.showCloseIcon.value;

  AdsUtilsCommon? adsUtilsCommon;

  late MediationType mediationType;

  ForeBackThCallback? _foreBackThCallback;

  DateTime? _appOpenLastShowTime;
  DateTime? _interstitialLastShowTime;
  DateTime? _rewardLastShowTime;

  bool shouldForeBackAppOpenShow = false;

  bool _hasAdShowing = false;

  bool _hasAdsInit = false;

  bool get hasAdsInit => _hasAdsInit;

  Future<void> init(
    MediationType mediaType,
    AdsConfig adsConfig, {
    String? sdkKey,
    FirebaseRemoteConfig? firebaseRemoteConfig,
  }) async {
    AdsConfigStore().adsConfig = adsConfig;
    mediationType = mediaType;
    switch (mediationType) {
      case MediationType.max:
        assert(sdkKey != null, 'Max sdkKey is must');
        adsUtilsCommon = AdsApplovin();
      case MediationType.admob:
        adsUtilsCommon = AdsAdmob();
    }
    if (adsUtilsCommon != null) {
      await adsUtilsCommon!.init(adsConfig, sdkKey);
      if (firebaseRemoteConfig != null) {
        await _adsRemoteConfig.init(remoteConfig: firebaseRemoteConfig);
        notifyListeners();
      }
      startLoad();
    }
  }

  Future<void> startLoad() async {
    if (_hasAdsInit) {
      return;
    }
    final PrivacyOptionsRequirementStatus status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    final bool canRequestAds =
        await ConsentInformation.instance.canRequestAds();
    if (status != PrivacyOptionsRequirementStatus.required) {
      _hasAdsInit = true;
      adsUtilsCommon!.activeAds();
      return;
    }
    if (canRequestAds) {
      _hasAdsInit = true;
      adsUtilsCommon!.activeAds();
    }
  }

  bool _intervalShowJudge(
    DateTime? lastShowTime,
    AdType adType,
    String scene,
    int defaultTime,
  ) {
    if (lastShowTime == null) {
      return true;
    }
    int? interval = _adsShowIntervalByScene[scene];
    if (interval != null) {
      return DateTime.now().difference(lastShowTime).inSeconds >= interval;
    }
    return DateTime.now().difference(lastShowTime).inSeconds >=
        (_adsShowInterval[adType] ?? defaultTime);
  }

  late final Map<AdType, AdsIntervalJudge> _adsIntervalShowJudge = {
    AdType.appOpen: (String scene) => _intervalShowJudge(
          _appOpenLastShowTime,
          AdType.appOpen,
          scene,
          60,
        ),
    AdType.interstitial: (String scene) => _intervalShowJudge(
          _interstitialLastShowTime,
          AdType.interstitial,
          scene,
          10,
        ),
    AdType.rewarded: (String scene) => _intervalShowJudge(
          _rewardLastShowTime,
          AdType.rewarded,
          scene,
          10,
        ),
  };

  void setDisableAdType(List<AdType> disableAdType) {
    _adsRemoteConfig.setDisableAdType(disableAdType);
  }

  void setDisableAdsScenes(List<String> disableAdsScenes) {
    _adsRemoteConfig.setDisableAdsScenes(disableAdsScenes);
  }

  void setAdsShowInterval(Map<AdType, int> adsShowInterval) {
    _adsRemoteConfig.setAdsShowInterval(adsShowInterval);
  }

  void setAdsShowIntervalByScene(Map<String, int> adsShowIntervalByScene) {
    _adsRemoteConfig.setAdsShowIntervalByScene(adsShowIntervalByScene);
  }

  bool shouldShowAds(AdType adType, String scene) {
    if (_hasAdShowing) {
      return false;
    }
    if (_disableAdType.contains(adType)) {
      return false;
    }
    if (_disableAdsScenes.contains(scene)) {
      return false;
    }
    if (_adsIntervalShowJudge.containsKey(adType)) {
      return _adsIntervalShowJudge[adType]?.call(scene) ?? false;
    }
    return false;
  }

  bool shouldShowWidgetAds(AdType adType, String scene) {
    if (_disableAdType.contains(adType)) {
      return false;
    }
    if (_disableAdsScenes.contains(scene)) {
      return false;
    }
    return true;
  }

  void setCallBack({
    AppOpenThAdCallback? appOpenThAdCallback,
    InterstitialThAdCallback? interstitialThAdCallback,
    RewardThAdCallback? rewardThAdCallback,
    BannerThAdCallback? bannerThAdCallback,
    NativeThAdCallback? nativeThAdCallback,
  }) {
    AdsConfigStore().appOpenThAdCallback = appOpenThAdCallback;
    AdsConfigStore().interstitialThAdCallback = interstitialThAdCallback;
    AdsConfigStore().rewardThAdCallback = rewardThAdCallback;
    AdsConfigStore().bannerThAdCallback = bannerThAdCallback;
    AdsConfigStore().nativeThAdCallback = nativeThAdCallback;
  }

  void activeAds() {
    adsUtilsCommon?.activeAds();
  }

  Future<bool> adReadyStatus(AdType adType) async {
    return await adsUtilsCommon?.checkAdsReady(adType) ?? false;
  }

  final List<AdState> _resetShowTimeAdState = [
    AdState.closed,
    AdState.rewarded,
  ];

  Future<AdState> showAppOpen(String scene) async {
    if (!shouldShowAds(AdType.appOpen, scene)) {
      return AdState.shouldNotShow;
    }
    _hasAdShowing = true;
    AdState? adState = await adsUtilsCommon?.showAppOpenAds(
      scene: scene,
    );
    _hasAdShowing = false;
    if (adState != null && _resetShowTimeAdState.contains(adState)) {
      _appOpenLastShowTime = DateTime.now();
      return adState;
    }
    return AdState.notReady;
  }

  Future<AdState> showInterstitial(String scene) async {
    if (!shouldShowAds(AdType.interstitial, scene)) {
      return AdState.shouldNotShow;
    }
    _hasAdShowing = true;
    AdState? adState = await adsUtilsCommon?.showInterstitialAds(
      scene: scene,
    );
    _hasAdShowing = false;
    if (adState != null && _resetShowTimeAdState.contains(adState)) {
      _interstitialLastShowTime = DateTime.now();
      return adState;
    }
    return AdState.notReady;
  }

  Future<AdState> showReward(String scene) async {
    if (!shouldShowAds(AdType.rewarded, scene)) {
      return AdState.shouldNotShow;
    }
    _hasAdShowing = true;
    AdState? adState = await adsUtilsCommon?.showRewardedAd(
      scene: scene,
    );
    _hasAdShowing = false;
    if (adState != null && _resetShowTimeAdState.contains(adState)) {
      _rewardLastShowTime = DateTime.now();
      return adState;
    }
    return AdState.notReady;
  }

  ///[setForeBackListener] 设置前后台监听
  void setForeBackListener(ForeBackThCallback? foreBackThCallback) {
    _foreBackThCallback = foreBackThCallback;
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) async {
      if (state == AppState.foreground) {
        debugPrint('App Foreground');
        if (shouldForeBackAppOpenShow) {
          await showAppOpen(AdsScene.oBacKToFore);
        }
        _foreBackThCallback?.foreStayCallback?.call();
      } else {
        debugPrint('App background');
        _foreBackThCallback?.backStayCallback?.call();
      }
    });
  }

  ///[setForeBackAppOpenShow] 是否展示AppOpen广告
  void setForeBackAppOpenShow(bool value) {
    shouldForeBackAppOpenShow = value;
  }

  void setWidgetAdsShow(bool value) {
    _adsRemoteConfig.setWidgetAdsShow(value);
    notifyListeners();
  }

  void setShowCloseIcon(bool value) {
    _adsRemoteConfig.setShowCloseIcon(value);
    notifyListeners();
  }

  void setShouldLoadAd(bool value) {
    AdsConfigStore().shouldLoadAds = value;
  }

  ///[showDebugger] 展示AD调试页面
  void showDebugger() {
    adsUtilsCommon?.showAdsDebugPage();
  }

  bool get shouldShowUMP => _adsRemoteConfig.appShouldShowUMP.value;

  void resetUmp() => UseUmp().resetUmp();

  void handleDealUmp({bool useTest = false}) async {
    UseUmp().umpLoadSuccessCall = () => startLoad();
    UseUmp().handleDealUmp(useTest: useTest);
  }
}
