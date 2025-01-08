import 'package:flutter/material.dart';

import '../ads_lib.dart';

class BannerWidgetAds extends StatelessWidget {
  const BannerWidgetAds({
    super.key,
    this.adScene,
    this.useSaveArea = false,
  });

  final String? adScene;
  final bool useSaveArea;

  @override
  Widget build(BuildContext context) {
    final AdsLib adsLib = AdsLib();

    return ListenableBuilder(
      listenable: adsLib,
      builder: (_, __) {
        if (!adsLib.shouldWidgetAdsShow) {
          return const SizedBox();
        }

        String? adUnitId = AdsConfigStore().adsConfig.banner;

        if (adUnitId == null || adUnitId.isEmpty) {
          return const SizedBox();
        }

        bool shouldShow = true;

        if (adScene != null) {
          shouldShow = adsLib.shouldShowWidgetAds(AdType.banner, adScene!);
        }

        if (!shouldShow) {
          return const SizedBox();
        }

        MediationType mediationType = adsLib.mediationType;

        return SafeArea(
          top: false,
          right: false,
          left: false,
          bottom: useSaveArea,
          child: SizedBox(
            child: () {
              if (mediationType == MediationType.max) {
                return ApplovinBannerWidget(
                  adsId: adUnitId,
                );
              } else if (mediationType == MediationType.admob) {
                return AdmobBannerWidget(
                  adsId: adUnitId,
                );
              } else {
                return const SizedBox();
              }
            }(),
          ),
        );
      },
    );
  }
}
