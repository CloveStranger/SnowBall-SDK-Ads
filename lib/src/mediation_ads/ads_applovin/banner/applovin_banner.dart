import 'package:applovin_max/applovin_max.dart';
import 'package:flutter_th_common_ads/flutter_th_common_ads.dart';

import '../../../ads_config_store.dart';

class ApplovinBanner extends AdsCommon {
  late String _adUnitId = '';

  @override
  void init() {
    _adUnitId = AdsConfigStore().adsConfig.banner ?? '';
    load();
  }

  @override
  bool preCheck() {
    return _adUnitId.isNotEmpty;
  }

  @override
  void load() {
    if (!preCheck()) return;
    AppLovinMAX.createBanner(_adUnitId, AdViewPosition.bottomCenter);
  }

  @override
  Future<bool> ready() {
    throw UnimplementedError();
  }

  @override
  Future<AdState> show(String scene) async {
    if (!preCheck()) return AdState.notReady;
    AppLovinMAX.showBanner(_adUnitId);
    return AdState.showSuccess;
  }
}
