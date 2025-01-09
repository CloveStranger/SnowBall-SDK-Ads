import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';

import '../../../ads_class.dart';
import '../../../ads_config_store.dart';
import '../../../ads_enums.dart';
import '../../../ads_lib.dart';
import '../../../ads_model.dart';
import '../../../ads_scene.dart';

class ApplovinBannerWidget extends StatefulWidget {
  const ApplovinBannerWidget({
    super.key,
    required this.adsId,
    this.adFormat,
    this.adScene = AdsScene.bDefault,
  });

  final AdFormat? adFormat;
  final String adsId;
  final String adScene;

  @override
  State<ApplovinBannerWidget> createState() => _ApplovinBannerWidgetState();
}

class _ApplovinBannerWidgetState extends State<ApplovinBannerWidget> {
  String get adsId => widget.adsId;

  String get adScene => widget.adScene;

  AdFormat get adFormat => widget.adFormat ?? AdFormat.banner;

  double _height = 0;

  BannerThAdCallback? _bannerThAdCallback() {
    return AdsConfigStore().bannerThAdCallback;
  }

  AdViewAdListener? get _adViewAdListener {
    return AdViewAdListener(
      onAdLoadedCallback: (ad) {
        _height = 50;
        setState(() {});
        _bannerThAdCallback()
            ?.onThAdLoadCallback
            ?.call(AdLoadedInfo(adUnitId: ad.adUnitId));
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _bannerThAdCallback()?.onThAdLoadFailedCallback?.call(
              AdErrorInfo(
                adUnitId: adUnitId,
                errorCode: error.code.value,
                errorMessage: error.message,
                mediationType: MediationType.max,
              ),
            );
      },
      onAdClickedCallback: (ad) {
        _bannerThAdCallback()?.onThAdClickedCallback?.call();
      },
      onAdExpandedCallback: (ad) {
        _bannerThAdCallback()?.onThAdExpandedCallback?.call();
      },
      onAdCollapsedCallback: (ad) {
        _bannerThAdCallback()?.onThAdCollapsedCallback?.call();
      },
      onAdRevenuePaidCallback: (ad) {
        _bannerThAdCallback()?.onThAdRevenuePaidCallback?.call(
              AdsPaidInfo(
                mediation: 'max',
                revenueFrom: 'applovin_max_ilrd',
                networkName: ad.networkName,
                adUnitId: ad.adUnitId,
                adType: AdType.banner,
                currency: 'USD',
                revenue: ad.revenue,
                revenuePrecision: ad.revenuePrecision,
                scene: adScene,
              ),
            );
      },
    );
  }

  Widget _buildCloseIcon() {
    if (!AdsLib().showCloseIcon) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () {
        _height = 0;
        setState(() {});
      },
      child: Align(
        alignment: Alignment.topRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.close_rounded,
            color: Colors.grey,
            size: 16,
          ),
        ),
      ),
    );
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MaxAdView(
                    isAutoRefreshEnabled: true,
                    adUnitId: adsId,
                    adFormat: adFormat,
                    listener: _adViewAdListener,
                  ),
                  _buildCloseIcon(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
