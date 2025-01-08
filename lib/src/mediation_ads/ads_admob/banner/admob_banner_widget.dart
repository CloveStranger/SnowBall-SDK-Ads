import 'package:flutter/material.dart';
import 'package:flutter_th_common_ads/flutter_th_common_ads.dart';
import 'package:flutter_th_common_ads/src/ads_config_store.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobBannerWidget extends StatefulWidget {
  const AdmobBannerWidget({
    super.key,
    required this.adsId,
    this.adScene = AdsScene.bDefault,
  });

  final String adsId;
  final String adScene;

  @override
  State<AdmobBannerWidget> createState() => _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends State<AdmobBannerWidget> {
  String get adsId => widget.adsId;

  String get adScene => widget.adScene;

  late BannerAd _bannerAd;

  bool _isLoaded = false;

  double _height = 0;

  BannerThAdCallback? _bannerThAdCallback() {
    return AdsConfigStore().bannerThAdCallback;
  }

  BannerAdListener get _bannerAdListener {
    return BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (ad) {
        debugPrint('$ad loaded.');
        _isLoaded = true;
        _height = 50;
        setState(() {});
        _bannerThAdCallback()?.onThAdLoadCallback?.call(
              AdLoadedInfo(adUnitId: ad.adUnitId),
            );
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (ad, err) {
        debugPrint('BannerAd failed to load: $err');
        // Dispose the ad here to free resources.
        ad.dispose();
        _bannerThAdCallback()?.onThAdLoadFailedCallback?.call(
              AdErrorInfo(
                adUnitId: adsId,
                errorCode: err.code,
                errorMessage: err.message,
                mediationType: MediationType.admob,
              ),
            );
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) {},
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) {
        _bannerThAdCallback()?.onThAdCollapsedCallback?.call();
      },
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) {
        _bannerThAdCallback()?.onThAdExpandedCallback?.call();
      },
      onAdClicked: (Ad ad) {
        _bannerThAdCallback()?.onThAdClickedCallback?.call();
      },
      onPaidEvent: (Ad ad, double valueMicros, PrecisionType precision,
          String currencyCode) {
        _bannerThAdCallback()?.onThAdRevenuePaidCallback?.call(
              AdsPaidInfo(
                mediation: 'admob',
                revenueFrom: 'admob_pingback',
                networkName: getNetworkName(ad.responseInfo),
                adUnitId: ad.adUnitId,
                adType: AdType.banner,
                currency: currencyCode,
                revenue: valueMicros * 1.0 / 1000000,
                revenuePrecision: precision.name,
                scene: adScene,
                thirdPartyAdPlacementId: null,
              ),
            );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: adsId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: _bannerAdListener,
    );
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdsLib(),
      builder: (_, __) {
        return AnimatedContainer(
          width: double.infinity,
          height: _height,
          duration: const Duration(milliseconds: 200),
          child: SingleChildScrollView(
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: AdWidget(ad: _bannerAd),
            ),
          ),
        );
      },
    );
  }
}
