import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../ads_class.dart';
import '../../../ads_config_store.dart';
import '../../../ads_enums.dart';
import '../../../ads_lib.dart';
import '../../../ads_model.dart';
import '../../../ads_scene.dart';

class AdmobNativeWidget extends StatefulWidget {
  const AdmobNativeWidget({
    super.key,
    required this.adsId,
    this.adScene = AdsScene.nDefault,
    this.child,
  });

  final String adsId;
  final String adScene;
  final Widget? child;

  @override
  State<AdmobNativeWidget> createState() => _AdmobNativeWidgetState();
}

class _AdmobNativeWidgetState extends State<AdmobNativeWidget>
    with TickerProviderStateMixin {
  NativeAd? _nativeAd;
  bool _adLoaded = false;

  NativeThAdCallback? _nativeThAdCallback() {
    return AdsConfigStore().nativeThAdCallback;
  }

  late final AnimationController animationController;
  late final Animation<double> animation;

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: widget.adsId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _adLoaded = true;
          animationController.forward();
          setState(() {});
          _nativeThAdCallback()?.onThAdLoadCallback?.call(
                AdLoadedInfo(
                  adUnitId: ad.adUnitId,
                ),
              );
        },
        onAdFailedToLoad: (ad, error) {
          // Dispose the ad here to free resources.
          debugPrint('$NativeAd failed to load: $error');
          ad.dispose();
          _nativeThAdCallback()?.onThAdLoadFailedCallback?.call(
                AdErrorInfo(
                  adUnitId: widget.adsId,
                  errorCode: error.code,
                  errorMessage: error.message,
                  mediationType: MediationType.admob,
                ),
              );
        },
        // Called when a click is recorded for a NativeAd.
        onAdClicked: (ad) {
          _nativeThAdCallback()?.onThAdClickedCallback?.call();
        },
        // Called when an impression occurs on the ad.
        onAdImpression: (ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (ad) {},
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (ad) {},
        // For iOS only. Called before dismissing a full screen view
        onAdWillDismissScreen: (ad) {},
        // Called when an ad receives revenue value.
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          _nativeThAdCallback()?.onThAdRevenuePaidCallback?.call(
                AdsPaidInfo(
                  mediation: 'admob',
                  revenueFrom: 'admob_pingback',
                  networkName: getNetworkName(ad.responseInfo),
                  adUnitId: ad.adUnitId,
                  adType: AdType.native,
                  currency: currencyCode,
                  revenue: valueMicros * 1.0 / 1000000,
                  revenuePrecision: precision.name,
                  scene: '',
                  thirdPartyAdPlacementId: null,
                ),
              );
        },
      ),
      request: const AdRequest(),
      // Styling
      nativeTemplateStyle: NativeTemplateStyle(
        // Required: Choose a template.
        templateType: TemplateType.medium,
        // Optional: Customize the ad's style.
        mainBackgroundColor: Colors.purple,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.cyan,
            backgroundColor: Colors.red,
            style: NativeTemplateFontStyle.monospace,
            size: 16.0),
        primaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.red,
            backgroundColor: Colors.cyan,
            style: NativeTemplateFontStyle.italic,
            size: 16.0),
        secondaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.green,
            backgroundColor: Colors.black,
            style: NativeTemplateFontStyle.bold,
            size: 16.0),
        tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.brown,
            backgroundColor: Colors.amber,
            style: NativeTemplateFontStyle.normal,
            size: 16.0),
      ),
    )..load();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.ease,
    );
    _loadAd();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 320, // minimum recommended width
          minHeight: 320, // minimum recommended height
          maxWidth: 400,
          maxHeight: 400,
        ),
        child: LayoutBuilder(
          builder: (_, constraints) {
            return ListenableBuilder(
              listenable: AdsLib(),
              builder: (_, __) {
                return Stack(
                  children: [
                    widget.child ?? const SizedBox(),
                    AnimatedBuilder(
                      animation: animationController,
                      builder: (BuildContext context, Widget? child) {
                        return Opacity(
                          opacity: animation.value,
                          child: SizedBox(
                            width: double.infinity,
                            height: constraints.maxHeight * animation.value,
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: constraints.maxHeight,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: () {
                                        if (_adLoaded) {
                                          return AdWidget(ad: _nativeAd!);
                                        }
                                        return const SizedBox();
                                      }(),
                                    ),
                                    () {
                                      if (!AdsLib().showCloseIcon) {
                                        return const SizedBox();
                                      }
                                      return Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            animationController.reverse();
                                          },
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                constraints.maxHeight / 10 / 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: constraints.maxHeight / 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    }()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
