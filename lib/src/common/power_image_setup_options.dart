import 'package:power_image/src/tools/power_image_monitor.dart';

class PowerImageSetupOptions {
  PowerImageSetupOptions(this.globalRenderType,
      {this.errorCallback, this.errorCallbackSamplingRate = 1.0});

  /// const String renderingTypeExternal = "external";
  /// const String renderingTypeTexture = "texture";
  final String globalRenderType;

  /// When an image loading error occurs, it will be called;
  final PowerImageErrorCallback? errorCallback;

  /// [0.000 ~ 1.000] means [0.0% ~ 100.0%]
  /// accuracy can achieve thousandth
  ///
  /// 0(0%):
  /// All devices don't trigger the callback
  ///
  /// 1(100%):
  /// All devices trigger the callback normally
  ///
  /// 0.1 means 10%;
  /// The device has a 10% chance of being hit,
  /// and being hit means that all error callbacks for this device will be executed.
  /// Please do not mistakenly understand that 10% of the exceptions of a single device will execute the callback
  final double? errorCallbackSamplingRate;
}
