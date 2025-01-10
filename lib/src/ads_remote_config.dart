import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../snowball_sdk_ads.dart';

class AdsRemoteConfig {
  static const String _disableAdTypesKey = 'ads_DisabledTypes';
  static const String _disableAdsScenesKey = 'ads_DisabledScenes';
  static const String _adsShowIntervalKey = 'ads_BaseInterval';
  static const String _adsShowIntervalBySceneKey = 'ads_IntervalByScene';
  static const String _adsShowCloseIcon = 'ads_ShowCloseIcon';
  static const String _appShouldShowUMP = 'app_ShouldShowUMP';
  static const String _adsLoadAppOpenAdDuration = 'ads_LoadAppOpenAdDuration';
  static const String _adsUnitIds = 'ads_UnitIds';
  static const String _adsUnitIdsAdmobBackup = 'ads_UnitIds_admob_backup';
  static const String _adsUnitIdsMaxBackup = 'ads_UnitIds_max_backup';

  late FirebaseRemoteConfig _firebaseRemoteConfig;

  List<AdType> disableAdType = <AdType>[];

  List<String> disableAdsScenes = <String>[];

  Map<AdType, int> adsShowInterval = <AdType, int>{
    AdType.appOpen: 60,
    AdType.interstitial: 10,
    AdType.rewarded: 10,
  };

  Map<String, int> adsShowIntervalByScene = <String, int>{};

  final ValueNotifier<bool> appShouldShowUMP = ValueNotifier<bool>(false);
  final ValueNotifier<bool> shouldWidgetAdsShow = ValueNotifier<bool>(true);
  final ValueNotifier<bool> showCloseIcon = ValueNotifier<bool>(false);

  Future<void> init({required FirebaseRemoteConfig remoteConfig}) async {
    _firebaseRemoteConfig = remoteConfig;
    await _firebaseRemoteConfig.ensureInitialized();
    _handleAppShouldShowUMP();
    _handleDisableAdTypes();
    _handleAdsShowCloseIcon();
    _handleAdsDisableScenes();
    _handleAdsBaseInterval();
    _handleAdsIntervalByScene();
  }

  void _handleAdsShowCloseIcon() {
    setShowCloseIcon(_firebaseRemoteConfig.getBool(_adsShowCloseIcon));
  }

  void _handleAppShouldShowUMP() {
    setAppShouldShowUMP(_firebaseRemoteConfig.getBool(_appShouldShowUMP));
  }

  void _handleDisableAdTypes() {}

  void _handleAdsDisableScenes() {
    final String disableScenes = _firebaseRemoteConfig.getString(
      _disableAdsScenesKey,
    );
    final dynamic decodeInfo = jsonDecode(disableScenes);
    if (decodeInfo is List<String>) {
      setDisableAdsScenes(decodeInfo);
    }
  }

  void _handleAdsBaseInterval() {
    final dynamic adsBaseInterval = jsonDecode(
      _firebaseRemoteConfig.getString(_adsShowIntervalKey),
    );
    if (adsBaseInterval is Map<String, int>) {
      setAdsShowInterval(
        <AdType, int>{
          AdType.appOpen: adsBaseInterval['appOpen'] ?? 30,
          AdType.interstitial: adsBaseInterval['interstitial'] ?? 15,
          AdType.rewarded: adsBaseInterval['rewarded'] ?? 5,
        },
      );
    }
  }

  void _handleAdsIntervalByScene() {
    final dynamic adsIntervalByScene = jsonDecode(
      _firebaseRemoteConfig.getString(_adsShowIntervalBySceneKey),
    );
    if (adsIntervalByScene is Map<String, int>) {
      setAdsShowIntervalByScene(
        adsIntervalByScene.map(
          (String key, int value) {
            return MapEntry<String, int>(key, value);
          },
        ),
      );
    }
  }

  void setDisableAdType(List<AdType> value) {
    disableAdType.clear();
    disableAdType = value;
  }

  void setDisableAdsScenes(List<String> value) {
    disableAdsScenes.clear();
    disableAdsScenes = value;
  }

  void setAdsShowInterval(Map<AdType, int> value) {
    adsShowInterval.clear();
    adsShowInterval = value;
  }

  void setAdsShowIntervalByScene(Map<String, int> value) {
    adsShowIntervalByScene.clear();
    adsShowIntervalByScene = value;
  }

  void setWidgetAdsShow(bool value) {
    shouldWidgetAdsShow.value = value;
  }

  void setShowCloseIcon(bool value) {
    showCloseIcon.value = value;
  }

  void setAppShouldShowUMP(bool value) {
    appShouldShowUMP.value = value;
  }
}
