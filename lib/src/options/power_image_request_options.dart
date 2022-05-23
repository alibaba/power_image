import 'package:flutter/cupertino.dart';

import 'power_image_request_options_src.dart';

const String renderingTypeExternal = "external";
const String renderingTypeTexture = "texture";
const String defaultGlobalRenderType = renderingTypeTexture;

const String imageTypeNetwork = "network";
const String imageTypeNativeAssert = "nativeAsset";
const String imageTypeAssert = "asset";
const String imageTypeFile = "file";

class PowerImageRequestOptions {
  PowerImageRequestOptions(
      {required this.src,
      required this.imageType,
      required this.renderingType,
      this.imageWidth,
      this.imageHeight});

  PowerImageRequestOptions.network(String src,
      {required this.renderingType, this.imageWidth, this.imageHeight})
      : src = PowerImageRequestOptionsSrcNormal(src: src),
        imageType = imageTypeNetwork;

  PowerImageRequestOptions.nativeAsset(String src,
      {required this.renderingType, this.imageWidth, this.imageHeight})
      : src = PowerImageRequestOptionsSrcNormal(src: src),
        imageType = imageTypeNativeAssert;

  PowerImageRequestOptions.asset(String src,
      {String? package,
      required this.renderingType,
      this.imageWidth,
      this.imageHeight})
      : src = PowerImageRequestOptionsSrcAsset(src: src, package: package),
        imageType = imageTypeAssert;

  PowerImageRequestOptions.file(String src,
      {required this.renderingType, this.imageWidth, this.imageHeight})
      : src = PowerImageRequestOptionsSrcNormal(src: src),
        imageType = imageTypeFile;

  final PowerImageRequestOptionsSrc src;
  final String imageType;
  final String? renderingType;
  final double? imageWidth;
  final double? imageHeight;

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
