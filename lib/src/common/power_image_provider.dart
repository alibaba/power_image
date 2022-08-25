import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:power_image/src/tools/power_image_monitor.dart';
import 'package:power_image_ext/image_provider_ext.dart';

import '../external/power_external_image_provider.dart';
import '../texture/power_texture_image_provider.dart';
import 'power_image_loader.dart';
import '../options/power_image_request_options.dart';

abstract class PowerImageProvider extends ImageProviderExt<PowerImageProvider> {
  factory PowerImageProvider.options(PowerImageRequestOptions options) {
    /// renderingType null case
    if (options.renderingType == null) {
      options = PowerImageRequestOptions(
          src: options.src,
          imageType: options.imageType,
          renderingType: PowerImageLoader.instance.globalRenderType,
          imageWidth: options.imageWidth,
          imageHeight: options.imageHeight);
    }

    /// must use one of renderingTypeExternal \ renderingTypeTexture
    assert(options.renderingType == renderingTypeExternal ||
        options.renderingType == renderingTypeTexture);
    if (options.renderingType == renderingTypeExternal) {
      return PowerExternalImageProvider(options);
    } else {
      return PowerTextureImageProvider(options);
    }
  }

  PowerImageRequestOptions options;

  PowerImageProvider(this.options, {this.scale = 1.0});

  double scale;

  @override
  ImageStreamCompleter load(PowerImageProvider key, DecoderCallback? decode) {
    _completer = OneFrameImageStreamCompleter(_loadAsync(key, decode));
    return _completer!;
  }

  ImageStreamCompleter? _completer;

  Future<ImageInfo> _loadAsync(
      PowerImageProvider key, DecoderCallback? decode) async {
    try {
      PowerImageCompleter powerImageCompleter =
          PowerImageLoader.instance.loadImage(options);
      Map map = await powerImageCompleter.completer!.future;
      bool? success = map['success'];

      // remove multiFrame image cache On Last Listener Removed
      bool? isMultiFrame = map['_multiFrame'];
      if (isMultiFrame == true) {
        _completer!
          .addOnLastListenerRemovedCallback(() {
            scheduleMicrotask(() {
              PaintingBinding.instance!.imageCache!.evict(key);
            });
          });
      }
      _completer = null;

      if (success != true) {
        // The network may be only temporarily unavailable, or the file will be
        // added on the server later. Avoid having future calls to resolve
        // fail to check the network again.
        final PowerImageLoadException exception =
            PowerImageLoadException(nativeResult: map);
        PowerImageMonitor.instance().anErrorOccurred(exception);
        throw exception;
      }
      return createImageInfo(map);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance!.imageCache!.evict(key);
      });
      rethrow;
    } finally {
      // chunkEvents.close();
    }
  }

  FutureOr<ImageInfo> createImageInfo(Map map);

  @override
  Future<PowerImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PowerImageProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    //TODO options判断相等
    if (other.runtimeType != runtimeType) return false;
    final PowerImageProvider typedOther = other;
    return options == typedOther.options && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(options, scale);

  @override
  String toString() => '$runtimeType("$options", scale: $scale)';

  @override
  void dispose() {}
}

class PowerImageLoadException implements Exception {
  /// Creates a [PowerImageLoadException] with the specified native State [state]
  /// and request [uniqueKey].
  PowerImageLoadException({required this.nativeResult})
      : assert(nativeResult != null),
        _message = 'Power Image request failed. For details, see the variable nativeResult';

  /// 0 = {map entry} "success" -> false
  /// 1 = {map entry} "uniqueKey" -> "{src: http://img.alicdn.com//bao//uploaded//i2//O1CN01SNnaus2KLND4UQngH_!!0-fleamarket.jpg}_imageTyp..."
  /// 2 = {map entry} "width" -> 0
  /// 3 = {map entry} "errMsg" -> "failPhenixEvent.getResultCode()=404"
  /// 4 = {map entry} "eventName" -> "onReceiveImageEvent"
  /// 5 = {map entry} "state" -> "loadFailed"
  /// 6 = {map entry} "height" -> 0
  final Map nativeResult;

  /// A human-readable error message.
  final String _message;

  @override
  String toString() => _message;
}
