import 'package:applovin_max/applovin_max.dart';

import '../../../ads_abstract_class.dart';
import '../../../ads_config_store.dart';
import '../../../ads_enums.dart';

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
