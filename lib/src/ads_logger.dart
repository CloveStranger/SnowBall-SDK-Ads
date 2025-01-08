import 'package:logger/logger.dart';

class AdsLogger {
  static Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printEmojis: false,
    ),
  );
}
