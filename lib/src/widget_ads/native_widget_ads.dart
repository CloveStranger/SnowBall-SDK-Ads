import 'package:flutter/material.dart';

import '../ads_config_store.dart';
import '../ads_enums.dart';
import '../ads_lib.dart';
import '../mediation_ads/ads_admob/native/admob_native_widget.dart';
import '../mediation_ads/ads_applovin/native/applovin_native_widget.dart';

class NativeWidgetAds extends StatelessWidget {
  const NativeWidgetAds({
    super.key,
    this.adScene,
    this.bgColor,
    this.padding,
    this.width,
    this.height,
    this.useSaveArea = true,
    this.child,
  });

  final String? adScene;
  final Color? bgColor;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool useSaveArea;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final AdsLib adsLib = AdsLib();

    return ListenableBuilder(
      listenable: adsLib,
      builder: (_, __) {
        if (!adsLib.shouldWidgetAdsShow) {
          return const SizedBox();
        }

        String? adUnitId = AdsConfigStore().adsConfig.native;

        if (adUnitId == null || adUnitId.isEmpty) {
          return const SizedBox();
        }

        bool shouldShow = true;

        if (adScene != null) {
          shouldShow = adsLib.shouldShowWidgetAds(AdType.native, adScene!);
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
          child: Container(
            constraints: BoxConstraints(
              maxWidth: width ?? double.infinity,
              maxHeight: height ?? 0,
            ),
            decoration: BoxDecoration(
              color: bgColor ?? const Color(0xff333333),
            ),
            child: () {
              if (mediationType == MediationType.max) {
                return AdsApplovinNativeWidget(
                  adsId: adUnitId,
                  child: child,
                );
              } else if (mediationType == MediationType.admob) {
                return AdmobNativeWidget(
                  adsId: adUnitId,
                  child: child,
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
