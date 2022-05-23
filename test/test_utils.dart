import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:power_image/power_image.dart';
import 'package:power_image/src/common/power_Image_platform_channel.dart';
import 'package:power_image/src/common/power_image_provider.dart';
import 'package:power_image_ext/image_info_ext.dart';
import 'dart:ui' as ui;

PowerImageRequestOptions testRequestOptions(
    {String src = 'src', String renderingType = renderingTypeTexture}) {
  return PowerImageRequestOptions(
      src: PowerImageRequestOptionsSrcNormal(src: src),
      renderingType: renderingType,
      imageType: 'test_custom',
      imageWidth: 11,
      imageHeight: 22);
}

PowerImageProvider testPowerImageProvider() {
  return PowerImageProvider.options(testRequestOptions());
}

Map testCompleteMap(
    {String? uniqueKey,
    bool success = false,
    int height = 1,
    int width = 2,
    int textureId = 0}) {
  return {
    'eventName': 'onReceiveImageEvent',
    'uniqueKey': uniqueKey ?? PowerImageLoader.completers.keys.first,
    'success': success,
    'height': height,
    'width': width,
    'textureId': textureId,
  };
}

Future<void> sendComplete(
    PowerImagePlatformChannel platformChannel, Map mockCompleteMap) async {

  return ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
    platformChannel.eventChannel.name,
    platformChannel.eventChannel.codec.encodeSuccessEnvelope(mockCompleteMap),
    (_) {},
  );
}

Future<PowerTextureImageInfo> testTextureImageInfo({int? textureId}) async {
  PowerTextureImageInfo textureImageInfo = await PowerTextureImageInfo.create(
      textureId: textureId, width: 10, height: 12);
  return textureImageInfo;
}

class TestPowerExternalImageProvider extends PowerImageProvider {
  TestPowerExternalImageProvider(PowerImageRequestOptions options)
      : super(options);
  @override
  FutureOr<ImageInfo> createImageInfo(Map map) {
    final Completer<ImageInfo> completer = Completer<ImageInfo>();
    ui.decodeImageFromPixels(
      Uint8List.fromList(
          List<int>.filled(1 * 1 * 4, 0, growable: false)),
      1,
      1,
      ui.PixelFormat.rgba8888,
          (ui.Image image) {
        completer.complete(ImageInfo(image: image));
      },
    );
    return completer.future;
  }
}