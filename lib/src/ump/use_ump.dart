import 'package:google_mobile_ads/google_mobile_ads.dart';

class UseUmp {
  factory UseUmp() {
    return UseUmp._makeInstance();
  }

  UseUmp._();

  factory UseUmp._makeInstance() {
    _instance ??= UseUmp._();
    return _instance!;
  }

  static UseUmp? _instance;

  UseUmp get instance => UseUmp._makeInstance();

  ///[debugSettings] only available for debug test
  final ConsentDebugSettings debugSettings = ConsentDebugSettings(
    debugGeography: DebugGeography.debugGeographyEea,
  );

  ///[resetUmp] only available for debug test
  Future<void> resetUmp() async {
    await ConsentInformation.instance.reset();
  }

  void Function()? umpLoadCall;
  void Function()? umpLoadErrorCall;
  void Function()? umpLoadSuccessCall;

  void _basicPrint(dynamic msg) {
    // debugPrint('======> UMP ${msg.toString()}');
  }

  Future<void> _successListener() async {
    ConsentForm.loadAndShowConsentFormIfRequired(
      (FormError? loadAndShowError) {
        umpLoadCall?.call();
        if (loadAndShowError != null) {
          umpLoadErrorCall?.call();
          _basicPrint('No consent form available. $loadAndShowError');
        } else {
          umpLoadSuccessCall?.call();
          _basicPrint('Consent Get');
        }
      },
    );
  }

  void _failureListener(FormError error) {}

  Future<void> handleDealUmp({bool useTest = false}) async {
    final ConsentRequestParameters params = ConsentRequestParameters();
    if (useTest) {
      params.consentDebugSettings = debugSettings;
    }
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      _successListener,
      _failureListener,
    );
  }
}
