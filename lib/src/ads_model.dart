import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uuid/uuid.dart';

import '../snowball_sdk_ads.dart';
import 'ads_constants.dart';

class AdsPaidInfo {
  AdsPaidInfo({
    required this.mediation,
    required this.revenueFrom,
    required this.networkName,
    required this.adUnitId,
    required this.adType,
    required this.currency,
    required this.revenue,
    required this.revenuePrecision,
    required this.scene,
    this.thirdPartyAdPlacementId,
  });

  final String mediation; // max, admob, self
  final String
      revenueFrom; // impression revenue provider, "applovin_max_ilrd, admob_pingback, self"
  final String impRecordId = const Uuid().v1();
  final String
      networkName; // Display name of the network which showed the ad (e.g. "AdColony")
  final String adUnitId; // The Ad Unit ID
  final String?
      thirdPartyAdPlacementId; // The ad's placement id, if any (bidding may not have one)
  final AdType
      adType; // The ad format of the ad (e.g. "BANNER", "MREC", "INTER", "REWARDED", "REWARDED_INTER")
  final String currency;
  final double revenue;
  final String revenuePrecision;
  final String scene;

  Map<String, dynamic> toJSON() {
    return {
      'mediation': mediation,
      'revenueFrom': revenueFrom,
      'impRecordId': impRecordId,
      'networkName': networkName,
      'adUnitId': adUnitId,
      'thirdPartyAdPlacementId': thirdPartyAdPlacementId,
      'adType': adType.name,
      'currency': currency,
      'revenue': revenue,
      'revenuePrecision': revenuePrecision,
      'scene': scene,
    };
  }
}

String getNetworkName(ResponseInfo? responseInfo) {
  if (responseInfo == null) {
    return 'Unknown';
  }

  String? adapterClassName = responseInfo.mediationAdapterClassName;

  if (adapterClassName == null) {
    return 'Unknown';
  }

  String networkName = adapterClassName;

  if (Platform.isIOS) {
    networkName = AdsConstants.adsAdapterMap['admob.AdMobAdapter'] ?? 'Unknown';
  } else if (Platform.isAndroid) {
    String prefix = 'com.google.ads.mediation.';
    if (adapterClassName.startsWith(prefix)) {
      String targetNetWorkName = adapterClassName.substring(prefix.length);
      networkName =
          AdsConstants.adsAdapterMap[targetNetWorkName] ?? targetNetWorkName;
    }
  }

  return networkName;
}

class AdLoadedInfo {
  AdLoadedInfo({
    required this.adUnitId,
  });

  String adUnitId;

  Map<String, dynamic> toJson() {
    return {
      'adUnitId': adUnitId,
    };
  }
}

class AdErrorInfo {
  AdErrorInfo({
    required this.adUnitId,
    required this.errorCode,
    required this.errorMessage,
    required this.mediationType,
  });

  String adUnitId;
  int errorCode;
  String errorMessage;
  MediationType mediationType;

  Map<String, dynamic> toJson() {
    return {
      'adUnitId': adUnitId,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'mediationType': mediationType.name,
    };
  }
}
