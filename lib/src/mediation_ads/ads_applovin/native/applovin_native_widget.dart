import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';

import '../../../ads_class.dart';
import '../../../ads_config_store.dart';
import '../../../ads_enums.dart';
import '../../../ads_lib.dart';
import '../../../ads_model.dart';
import '../../../ads_scene.dart';

class AdsApplovinNativeWidget extends StatefulWidget {
  const AdsApplovinNativeWidget({
    super.key,
    required this.adsId,
    this.adScene = AdsScene.nDefault,
    this.child,
  });

  final String adsId;
  final String adScene;
  final Widget? child;

  @override
  State<AdsApplovinNativeWidget> createState() =>
      _AdsApplovinNativeWidgetState();
}

class _AdsApplovinNativeWidgetState extends State<AdsApplovinNativeWidget>
    with TickerProviderStateMixin {
  bool adsCanShow = false;
  double adsAspectRatio = 1;

  NativeThAdCallback? _nativeThAdCallback() {
    return AdsConfigStore().nativeThAdCallback;
  }

  late final AnimationController animationController;
  late final Animation<double> animation;

  final MaxNativeAdViewController _nativeAdViewController =
      MaxNativeAdViewController();

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
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                                  child: MaxNativeAdView(
                                    controller: _nativeAdViewController,
                                    adUnitId: widget.adsId,
                                    listener: NativeAdListener(
                                      onAdLoadedCallback: (ad) {
                                        setState(() {
                                          adsCanShow = true;
                                          animationController.forward();
                                          adsAspectRatio = ad.nativeAd
                                                  ?.mediaContentAspectRatio ??
                                              1;
                                        });
                                        _nativeThAdCallback()
                                            ?.onThAdLoadCallback
                                            ?.call(
                                              AdLoadedInfo(
                                                  adUnitId: ad.adUnitId),
                                            );
                                      },
                                      onAdLoadFailedCallback:
                                          (adUnitId, error) {
                                        _nativeThAdCallback()
                                            ?.onThAdLoadFailedCallback
                                            ?.call(
                                              AdErrorInfo(
                                                adUnitId: adUnitId,
                                                errorCode: error.code.value,
                                                errorMessage: error.message,
                                                mediationType:
                                                    MediationType.max,
                                              ),
                                            );
                                      },
                                      onAdClickedCallback: (ad) {
                                        _nativeThAdCallback()
                                            ?.onThAdClickedCallback
                                            ?.call();
                                      },
                                      onAdRevenuePaidCallback: (ad) {
                                        _nativeThAdCallback()
                                            ?.onThAdRevenuePaidCallback
                                            ?.call(
                                              AdsPaidInfo(
                                                mediation: 'max',
                                                revenueFrom:
                                                    'applovin_max_ilrd',
                                                networkName: ad.networkName,
                                                adUnitId: ad.adUnitId,
                                                adType: AdType.native,
                                                currency: 'USD',
                                                revenue: ad.revenue,
                                                revenuePrecision:
                                                    ad.revenuePrecision,
                                                scene: '',
                                              ),
                                            );
                                      },
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child:
                                                    const MaxNativeAdIconView(
                                                  width: 48,
                                                  height: 48,
                                                ),
                                              ),
                                              const Flexible(
                                                child: DefaultTextStyle(
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      MaxNativeAdTitleView(
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 13,
                                                          height: 1.5,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                                      MaxNativeAdAdvertiserView(
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 11,
                                                          height: 1.1,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.fade,
                                                      ),
                                                      MaxNativeAdStarRatingView(
                                                        size: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const MaxNativeAdOptionsView(
                                                width: 20,
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          const DefaultTextStyle(
                                            style: TextStyle(),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: MaxNativeAdBodyView(
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: AspectRatio(
                                              aspectRatio: adsAspectRatio,
                                              child:
                                                  const MaxNativeAdMediaView(),
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: MaxNativeAdCallToActionView(
                                              style: ButtonStyle(
                                                shape: WidgetStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      4,
                                                    ), // 设置圆角半径
                                                  ),
                                                ),
                                                backgroundBuilder:
                                                    (_, __, child) {
                                                  return DefaultTextStyle(
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xffff504d),
                                                            Color(0xffff7a2e),
                                                          ],
                                                        ),
                                                      ),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                textStyle:
                                                    const WidgetStatePropertyAll<
                                                        TextStyle>(
                                                  TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                          borderRadius: BorderRadius.circular(
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
    );
  }
}
