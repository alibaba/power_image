import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:power_image/src/common/power_image_provider.dart';
import 'package:power_image/src/options/power_image_request_options.dart';
import 'package:power_image_ext/image_info_ext.dart';
import '../../power_image.dart';

class PowerTextureImageProvider extends PowerImageProvider {
  PowerTextureImageProvider(PowerImageRequestOptions options) : super(options);

  @override
  FutureOr<ImageInfo> createImageInfo(Map map) {
    int? textureId = map['textureId'];
    int? width = map['width'];
    int? height = map['height'];
    return PowerTextureImageInfo.create(
        textureId: textureId, width: width, height: height);
  }

  @override
  void dispose() {
    PowerImageLoader.instance.releaseImageRequest(options);
    super.dispose();
  }
}
