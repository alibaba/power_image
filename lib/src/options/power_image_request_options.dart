import 'package:flutter/cupertino.dart';
import 'package:power_image/src/tools/power_num_safe.dart';

import 'power_image_request_options_src.dart';

const String renderingTypeExternal = "external";
const String renderingTypeTexture = "texture";
const String defaultGlobalRenderType = renderingTypeTexture;

const String imageTypeNetwork = "network";
const String imageTypeNativeAsset = "nativeAsset";
const String imageTypeAsset = "asset";
const String imageTypeFile = "file";

class PowerImageRequestOptions {
  PowerImageRequestOptions(
      {required this.src,
      required this.imageType,
      required this.renderingType,
      double? imageWidth,
      double? imageHeight})
      : assert(isNumValid(imageWidth), 'imageWidth is a Invalid value!'),
        _imageWidth = makeNumValid(imageWidth, null),
        assert(isNumValid(imageHeight), 'imageHeight is a Invalid value!'),
        _imageHeight = makeNumValid(imageHeight, null);

  PowerImageRequestOptions.network(String src,
      {required this.renderingType, double? imageWidth, double? imageHeight})
      : src = PowerImageRequestOptionsSrcNormal(src: src),
        imageType = imageTypeNetwork,
        assert(isNumValid(imageWidth), 'imageWidth is a Invalid value!'),
        _imageWidth = makeNumValid(imageWidth, null),
        assert(isNumValid(imageHeight), 'imageHeight is a Invalid value!'),
        _imageHeight = makeNumValid(imageHeight, null);

  PowerImageRequestOptions.nativeAsset(String src,
      {required this.renderingType, double? imageWidth, double? imageHeight})
      : src = PowerImageRequestOptionsSrcNormal(src: src),
        imageType = imageTypeNativeAsset,
        assert(isNumValid(imageWidth), 'imageWidth is a Invalid value!'),
        _imageWidth = makeNumValid(imageWidth, null),
        assert(isNumValid(imageHeight), 'imageHeight is a Invalid value!'),
        _imageHeight = makeNumValid(imageHeight, null);

  PowerImageRequestOptions.asset(String src,
      {String? package,
      required this.renderingType,
      double? imageWidth,
      double? imageHeight})
      : src = PowerImageRequestOptionsSrcAsset(src: src, package: package),
        imageType = imageTypeAsset,
        assert(isNumValid(imageWidth), 'imageWidth is a Invalid value!'),
        _imageWidth = makeNumValid(imageWidth, null),
        assert(isNumValid(imageHeight), 'imageHeight is a Invalid value!'),
        _imageHeight = makeNumValid(imageHeight, null);

  PowerImageRequestOptions.file(String src,
      {required this.renderingType, double? imageWidth, double? imageHeight})
      : src = PowerImageRequestOptionsSrcNormal(src: src),
        imageType = imageTypeFile,
        assert(isNumValid(imageWidth), 'imageWidth is a Invalid value!'),
        _imageWidth = makeNumValid(imageWidth, null),
        assert(isNumValid(imageHeight), 'imageHeight is a Invalid value!'),
        _imageHeight = makeNumValid(imageHeight, null);

  final PowerImageRequestOptionsSrc src;
  final String imageType;
  final String? renderingType;

  double? get imageWidth => _imageWidth;
  final double? _imageWidth;

  double? get imageHeight => _imageHeight;
  final double? _imageHeight;

  @override
  String toString() {
    return 'src: $src, imageType: $imageType, renderingType: $renderingType';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is PowerImageRequestOptions &&
        other.src == src &&
        other.imageType == imageType &&
        other.imageWidth == imageWidth &&
        other.imageHeight == imageHeight;
  }

  @override
  //todo hashValues(src, imageType) will make different hashCode
  int get hashCode => hashValues(src, imageType, imageWidth, imageHeight);
}
