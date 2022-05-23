import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:power_image/src/common/power_image_provider.dart';

typedef PowerImageErrorCallback = void Function(
    PowerImageLoadException exception);

/// setup with PowerImageSetupOptions;
class PowerImageMonitor {
  PowerImageMonitor._internal() {
    _init();
  }

  static final PowerImageMonitor _singleton = PowerImageMonitor._internal();

  void _init() {}

  static PowerImageMonitor instance() {
    return _singleton;
  }

  PowerImageErrorCallback? errorCallback;
  bool _needCallError = false;
  set errorCallbackSamplingRate(double? r) {
    r = (r ?? 1.00).clamp(0.000, 1.000);
    if (0.0 == r) {
      _needCallError = false;
      return;
    } else if (1.0 == r) {
      _needCallError = true;
      return;
    }
    final int num = (r * 1000).toInt().clamp(0, 1000);
    final int randomNum = Random().nextInt(1000) + 1;
    _needCallError = randomNum <= num;
  }

  void anErrorOccurred(PowerImageLoadException exception) {
    if (_needCallError) {
      errorCallback?.call(exception);
    }
  }

  @visibleForTesting
  bool get needCallError => _needCallError;
}
